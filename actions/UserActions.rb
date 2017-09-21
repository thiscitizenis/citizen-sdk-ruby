class UserActions

    def UserActions.createUser(email:,
                               password:,
                               passPhrase:,
                               ecdsa: nil)
        
        user = User.new()
        user.primaryEmail=email
        user.password=password
        user.passPhrase=passPhrase

        if !ecdsa.nil? && ecdsa.hasLocalPublicKey()
            user.authPublicKey = ecdsa.exportLocalPublicKey(format: ECPublicKeyFormats::BASE_64_ENCODED_DER)
        end

        response = RestClientWrapper::sendRequest(method: 'post',
                                                  endpoint: 'users',
                                                  content: user)

        if response.code == 409
            raise RuntimeError.new('UserActions.createUser: user already exists')
        elsif response.code != 200
            raise RuntimeError.new("UserActions.createUser: error running request: response code: #{response.code}")
        end

        return User.new.fromHash(JSON.parse(response.body))
    end


    def UserActions.login(email:,
                          password:)

        user = User.new()
        user.primaryEmail=email
        user.password=password

        response = RestClientWrapper::sendRequest(method: 'post',
                                                  endpoint: 'sessions',
                                                  content: user)

        if response.code != 200
            raise RuntimeError.new("UserActions.login: error running request: response code: #{response.code}")
        end

        return User.new.fromHash(JSON.parse(response.body))
    end


    def UserActions.getMnemonic(user:,
                                passPhrase:)

        user.passPhrase=passPhrase

        response = RestClientWrapper::sendRequest(method: 'post',
                                                  endpoint: 'sessions/mnemonic',
                                                  content: user)

        if response.code != 200
            raise RuntimeError.new("UserActions.getMnemonic: error running request: response code: #{response.code}")
        end

        return response.body
    end


    def UserActions.enrollDevicePublicKey(userId:,
                                          ecdsa:,
                                          apiKey:)

        if !ecdsa.hasLocalPublicKey()
            raise RuntimeError.new('UserActions.enrollDevicePublicKey: ecdsa not initialised with public key')
        end

        exportedPubKey = ecdsa.exportLocalPublicKey(format: ECPublicKeyFormats::BASE_64_ENCODED_DER)

        response = RestClientWrapper::sendRequest(method: 'post',
                                                  endpoint: "users/#{userId}/publicKey",
                                                  content: exportedPubKey,
                                                  apiKey: apiKey)

        
        if response.code != 200
            raise RuntimeError.new("UserActions.enrollDevicePublicKey: error running request: response code: #{response.code}")
        end

        return User.new.fromHash(JSON.parse(response.body))
    end


    def UserActions.loginWithSignedTransaction(email:, ecdsa:)

        if !ValueCheck.checkEmailAddress(email)
            raise ArgumentError.new('UserActions.loginWithSignedTransaction: username must be an email address string')
        end
        if !ecdsa.is_a?(ECDSA)
            raise ArgumentError.new('UserActions.loginWithSignedTransaction: ecdsa must be an ECDSA object')
        end

        if !ecdsa.hasLocalPrivateKey()
            raise RuntimeError.new('UserActions.loginWithSignedTransaction: ecdsa not initialised with private key')
        end

        response = RestClientWrapper::sendRequest(method: 'get',
                                                  endpoint: 'sessions/getLoginNonce')

        if response.code != 200
            raise RuntimeError.new("UserActions.getWebTokenLoginNonce: error running request: response code: #{response.code}")
        end

        loginNonce = response.body

        loginTransaction = LoginTransaction.new()
        loginTransaction.username=email
        loginTransaction.token=loginNonce

        signedTransaction = ecdsa.sign(loginTransaction.getDataToSign())

        response = RestClientWrapper::sendRequest(method: 'post',
                                                  endpoint: 'sessions/auth',
                                                  content: loginTransaction,
                                                  loginSignature: signedTransaction)

        if response.code != 200
            raise RuntimeError.new("UserActions.loginWithSignedTransaction: error running request: response code: #{response.code}")
        end

        return User.new.fromHash(JSON.parse(response.body))
    end


    def UserActions.getWebTokenLoginNonce()

        response = RestClientWrapper::sendRequest(method: 'get',
                                                  endpoint: 'webapp/login/web/getSessionNonce')

        if response.code != 200
            raise RuntimeError.new("UserActions.getWebTokenLoginNonce: error running request: response code: #{response.code}")
        end

        return response.body
    end


    def UserActions.generateWebLoginToken(nonce:,
                                          email:,
                                          ecdhPublicKey:)

        webLoginIdentifyingDetails = WebLoginIdentifyingDetails.new
        webLoginIdentifyingDetails.nonce=nonce
        webLoginIdentifyingDetails.email=email
        webLoginIdentifyingDetails.browserECDHPublicKey=ecdhPublicKey

        response = RestClientWrapper::sendRequest(method: 'post',
                                                  endpoint: 'webapp/login/web/generateToken',
                                                  content: webLoginIdentifyingDetails)

        if response.code != 200
            raise RuntimeError.new("UserActions.generateWebLoginToken: error running request: response code: #{response.code}")
        end

        return true
    end


    def UserActions.getWebTokenLoginDetils(nonce:)
        
        webStompClient = WebStompClient.new()

        loginDetails = webStompClient.sendStompMessageAndReceiveResponse(
                           webSocketEndpoint: 'webapp/tokenLoginSock',
                           stompSendLocation: "/webapp/tokenLogin/request/#{nonce}",
                           stompReceiveLocation: "/tokenLogin/response/#{nonce}",
                           message: nonce,
                           contentType: 'text/plain'
                       )

        webLoginAuthDetails = WebLoginAuthDetails.new().fromHash(JSON.parse(loginDetails))

        if webStompClient.state != WebStompClient::WebStompState::FINISHED
            raise RuntimeError.new("UserActions.getWebTokenLoginDetils: error running request: STOMP session state : #{webStompClient.state}")
        end

        return webLoginAuthDetails
    end


    def UserActions.webLoginFromToken(email:)

        ecdh = ECDH.new()
        ecdh.generateLocalKey()

        localPublicKey = ecdh.exportLocalPublicKey(format: ECPublicKeyFormats::XY_HEXADECIMAL)

        nonce = UserActions.getWebTokenLoginNonce()

        UserActions.generateWebLoginToken(nonce: nonce,
                                          email: email,
                                          ecdhPublicKey: localPublicKey)

        webLoginAuthDetails = UserActions.getWebTokenLoginDetils(nonce: nonce)

        ecdh.importRemotePublicKey(format: ECPublicKeyFormats::XY_HEXADECIMAL,
                                   keyData: webLoginAuthDetails.phonePubKey)

        temporaryKey = ecdh.getSharedSecret()

        webLoginSessionDetails = WebLoginSessionDetails.new()
        webLoginSessionDetails.email=email
        webLoginSessionDetails.apiKey=webLoginAuthDetails.apiKey
        webLoginSessionDetails.sessionNonce=nonce
        webLoginSessionDetails.sessionKey=temporaryKey

        return webLoginSessionDetails
    end
end
