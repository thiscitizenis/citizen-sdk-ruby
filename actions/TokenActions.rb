class TokenActions

    def TokenActions.createToken(requestorEmail:,
                                 userEmail:,
                                 access:,
                                 durationType:,
                                 duration:,
                                 apiKey:,
                                 mnemonic: nil,
                                 sessionNonce: nil,
                                 sessionKey: nil)

        if !(!mnemonic.nil? || (!sessionNonce.nil? && !sessionKey.nil?))
            raise ArgumentError.new('TokenActions.createToken: either mnemonic or both sessionNonce and sessionKey must be given')
        end

        token = Token.new

        token.tokenStatus=TokenStatus::REQUESTED
        token.requesterEmail=requestorEmail
        token.userEmail=userEmail
        token.access=access.access
        token.durationType=durationType
        token.duration=duration

        response = RestClientWrapper::sendRequest(method: 'post',
                                                  endpoint: 'tokens',
                                                  content: token,
                                                  apiKey: apiKey,
                                                  mnemonic: mnemonic,
                                                  sessionNonce: sessionNonce,
                                                  sessionKey: sessionKey)

        if response.code != 200
            raise RuntimeError.new("TokenActions.createToken: error running request: response code: #{response.code}")
        end

        return Token.new.fromHash(JSON.parse(response.body))
    end


    def TokenActions.getToken(tokenId:,
                              apiKey:,
                              mnemonic: nil,
                              sessionNonce: nil,
                              sessionKey: nil)

        if !(!mnemonic.nil? || (!sessionNonce.nil? && !sessionKey.nil?))
            raise ArgumentError.new('TokenActions.getToken: either mnemonic or both sessionNonce and sessionKey must be given')
        end

        response = RestClientWrapper::sendRequest(method: 'get',
                                                  endpoint: "tokens/#{tokenId}",
                                                  apiKey: apiKey,
                                                  mnemonic: mnemonic,
                                                  sessionNonce: sessionNonce,
                                                  sessionKey: sessionKey)

        if response.code != 200
            raise RuntimeError.new("TokenActions.getToken: error running request: response code: #{response.code}")
        end

        return Token.new.fromHash(JSON.parse(response.body))
    end


    def TokenActions.getUserTokens(apiKey:,
                                   mnemonic: nil,
                                   sessionNonce: nil,
                                   sessionKey: nil)

        if !(!mnemonic.nil? || (!sessionNonce.nil? && !sessionKey.nil?))
            raise ArgumentError.new('TokenActions.getUserTokens: either mnemonic or both sessionNonce and sessionKey must be given')
        end

        response = RestClientWrapper::sendRequest(method: 'get',
                                                  endpoint: 'tokens/user',
                                                  apiKey: apiKey,
                                                  mnemonic: mnemonic,
                                                  sessionNonce: sessionNonce,
                                                  sessionKey: sessionKey)

        if response.code != 200
            raise RuntimeError.new("TokenActions.getUserTokens: error running request: response code: #{response.code}")
        end

        return TokenWrapper.new.fromHash(JSON.parse(response.body))
    end


    def TokenActions.getRequesterTokens(apiKey:,
                                        mnemonic: nil,
                                        sessionNonce: nil,
                                        sessionKey: nil)

        if !(!mnemonic.nil? || (!sessionNonce.nil? && !sessionKey.nil?))
            raise ArgumentError.new('TokenActions.getRequesterTokens: either mnemonic or both sessionNonce and sessionKey must be given')
        end

        response = RestClientWrapper::sendRequest(method: 'get',
                                                  endpoint: 'tokens/requester',
                                                  apiKey: apiKey,
                                                  mnemonic: mnemonic,
                                                  sessionNonce: sessionNonce,
                                                  sessionKey: sessionKey)

        if response.code != 200
            raise RuntimeError.new("TokenActions.getRequesterTokens: error running request: response code: #{response.code}")
        end

        return TokenWrapper.new.fromHash(JSON.parse(response.body))
    end



    def TokenActions.grantToken(token:,
                                apiKey:,
                                mnemonic: nil,
                                sessionNonce: nil,
                                sessionKey: nil)

        if !(!mnemonic.nil? || (!sessionNonce.nil? && !sessionKey.nil?))
            raise ArgumentError.new('TokenActions.grantToken: either mnemonic or both sessionNonce and sessionKey must be given')
        end

        if token.id.nil?
            raise RuntimeError.new('TokenActions.grantToken: token not initialised')
        end

        if !token.metaData.nil?
            response = RestClientWrapper::sendRequest(method: 'put',
                                                      endpoint: "tokens/#{token.id}/GRANTED",
                                                      content: token.metaData,
                                                      apiKey: apiKey,
                                                      mnemonic: mnemonic,
                                                      sessionNonce: sessionNonce,
                                                      sessionKey: sessionKey)
        else
            response = RestClientWrapper::sendRequest(method: 'put',
                                                      endpoint: "tokens/#{token.id}/GRANTED",
                                                      apiKey: apiKey,
                                                      mnemonic: mnemonic,
                                                      sessionNonce: sessionNonce,
                                                      sessionKey: sessionKey)
        end

        if response.code != 200
            raise RuntimeError.new("TokenActions.grantToken: error running request: response code: #{response.code}")
        end

        return Token.new.fromHash(JSON.parse(response.body))
    end


    def TokenActions.declineToken(tokenId:,
                                  apiKey:,
                                  mnemonic: nil,
                                  sessionNonce: nil,
                                  sessionKey: nil)

        if !(!mnemonic.nil? || (!sessionNonce.nil? && !sessionKey.nil?))
            raise ArgumentError.new('TokenActions.declineToken: either mnemonic or both sessionNonce and sessionKey must be given')
        end

        response = RestClientWrapper::sendRequest(method: 'put',
                                                  endpoint: "tokens/#{tokenId}/DECLINED",
                                                  apiKey: apiKey,
                                                  mnemonic: mnemonic,
                                                  sessionNonce: sessionNonce,
                                                  sessionKey: sessionKey)

        if response.code != 200
            raise RuntimeError.new("TokenActions.declineToken: error running request: response code: #{response.code}")
        end

        return Token.new.fromHash(JSON.parse(response.body))
    end


    def TokenActions.deleteToken(tokenId:,
                                 apiKey:,
                                 mnemonic: nil,
                                 sessionNonce: nil,
                                 sessionKey: nil)

        if !(!mnemonic.nil? || (!sessionNonce.nil? && !sessionKey.nil?))
            raise ArgumentError.new('TokenActions.deleteToken: either mnemonic or both sessionNonce and sessionKey must be given')
        end

        response = RestClientWrapper::sendRequest(method: 'delete',
                                                  endpoint: "tokens/#{tokenId}",
                                                  apiKey: apiKey,
                                                  mnemonic: mnemonic,
                                                  sessionNonce: sessionNonce,
                                                  sessionKey: sessionKey)

        if response.code != 200
            raise RuntimeError.new("TokenActions.deleteToken: error running request: response code: #{response.code}")
        end

        return true
    end


    def TokenActions.signToken(token:,
                               ecdsa:)

        if !token.is_a?(Token)
            raise ArgumentError.new('TokenActions.signToken: token must be a Token object')
        end
        if !ecdsa.is_a?(ECDSA)
            raise ArgumentError.new('TokenActions.signToken: ecdsa must be an ECDSA object')
        end

        if token.id.nil?
            raise RuntimeError.new('TokenActions.signToken: token not initialised')
        end

        if !ecdsa.hasLocalPrivateKey()
            raise RuntimeError.new('TokenActions.signToken: ecdsa not initialised with private key')
        end

        signedTokenId = ecdsa.sign(token.id)

        token.setProperty(PropertyType::SIGNED_TOKEN_ID, signedTokenId)

        return token
    end


    def TokenActions.verifySignedToken(token:,
                                       apiKey:)

        if !token.is_a?(Token)
            raise ArgumentError.new('TokenActions.verifyToken: token must be a Token object')
        end

        if token.id.nil?
            raise RuntimeError.new('TokenActions.verifyToken: token not initialised')
        end

        if token.hashedUserEmail.nil?
            raise RuntimeError.new('TokenActions.verifyToken: does not have a hashed email')
        end

        response = RestClientWrapper::sendRequest(method: 'get',
                                                  endpoint: "users/#{token.hashedUserEmail}/devicePublicKey",
                                                  apiKey: apiKey)

        if response.code != 200
            raise RuntimeError.new("TokenActions.verifySignedToken: error running request: response code: #{response.code}")
        end

        devicePublicKey = response.body

        ecdsa = ECDSA.new()
        ecdsa.ecCurve=ECCurves::P256

        ecdsa.importRemotePublicKey(format: ECPublicKeyFormats::BASE_64_ENCODED_DER,
                                    keyData: devicePublicKey)

        if !ecdsa.hasRemotePublicKey()
            raise RuntimeError.new('TokenActions.verifyToken: unable to import device public key')
        end

        signedTokenId = token.getProperty(PropertyType::SIGNED_TOKEN_ID)

        if signedTokenId.nil?
            return false
        end

        return ecdsa.verify(token.id, signedTokenId)
    end
end
