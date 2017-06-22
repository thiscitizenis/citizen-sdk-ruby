# Note here that 'key pair' refers to a pair of EC keys rather than the
# public/private parts of a single EC key. This is to facilitate ECDH.

class ECKeyPair

    EC_HEX_COORDINATE_LENGTHS = { 'prime256v1' => 64, 'secp384r1' => 96 }

    attr_reader :ecCurve,
                :localKey,
                :remoteKey

    def initialize()
        @ecCurve   = nil   # ECCurves string
        @localKey  = nil   # OpenSSL::PKey::EC
        @remoteKey = nil   # OpenSSL::PKey::EC
    end


    def ecCurve=(ecCurve)
        if !ValueCheck.checkStringConstant(ecCurve, ECCurves)
            raise ArgumentError.new('ECKeyPair: EC Curve not supported')
        end
        @ecCurve = ecCurve
    end


    def generateLocalKey()
        if @ecCurve.nil?
            raise ArgumentError.new('ECKeyPair: EC Curve name must be set')
        end
        @localKey = OpenSSL::PKey::EC.new(@ecCurve)
        @localKey.generate_key()
    end


    def hasLocalPrivateKey()
        if !@localKey.nil?
            return !@localKey.private_key.nil?
        end
 
        return false
    end


    def hasLocalPublicKey()
        if !@localKey.nil?
            return !@localKey.public_key.nil?
        end

        return false
    end


    def hasRemotePrivateKey()
        if !@remoteKey.nil?
            return !@remoteKey.private_key.nil?
        end
 
        return false
    end


    def hasRemotePublicKey()
        if !@remoteKey.nil?
            return !@remoteKey.public_key.nil?
        end

        return false
    end


    def importLocalPrivateKey(format:, keyData:, password: nil)
        @localKey = importPrivateKey(key: @localKey, format: format, keyData: keyData, password: password) 
    end


    def importLocalPublicKey(format:, keyData:, password: nil)
        @localKey = importPublicKey(key: @localKey, format: format, keyData: keyData, password: password)
    end


    def importRemotePrivateKey(format:, keyData:, password: nil)
        @remoteKey = importPrivateKey(key: @remoteKey, format: format, keyData: keyData, password: password)
    end


    def importRemotePublicKey(format:, keyData:, password: nil)
        @remoteKey = importPublicKey(key: @remoteKey, format: format, keyData: keyData, password: password)
    end


    def exportLocalPrivateKey(format:, password: nil)
        return exportPrivateKey(key: @localKey, format: format, password: password)
    end


    def exportLocalPublicKey(format:, password: nil)
        return exportPublicKey(key: @localKey, format: format, password: password)
    end


    def exportRemotePrivateKey(format:, password: nil)
        return exportPrivateKey(key: @remoteKey, format: format, password: password)
    end


    def exportRemotePublicKey(format:, password: nil)
        return exportPublicKey(key: @localKey, format: format, password: password)
    end


    def fromHash(attributeHash)
        @localKey = OpenSSL::PKey::EC.new(@ecCurve)
        @remoteKey = OpenSSL::PKey::EC.new(@ecCurve)

        if !attributeHash.nil?
            if !ValueCheck.checkStringConstant(attributeHash['ecCurve'], ECCurves)
                raise ArgumentError.new('ECKeyPair: EC Curve not supported')
            end
            @ecCurve = attributeHash['ecCurve']

            if !attributeHash['localKey'].nil?
                if !attributeHash['localKey']['private'].nil?
                    verifyPrivateKeyHexString(attributeHash['localKey']['private'])
                    importPrivateKeyFromHexString(@localKey, attributeHash['localKey']['private'])
                end
                if !attributeHash['localKey']['public'].nil?
                    verifyPublicKeyXYHexString(attributeHash['localKey']['public'])
                    importPublicKeyFromXYHexString(@localKey, attributeHash['localKey']['public'])
                end
            end

            if !attributeHash['remoteKey'].nil?
                if !attributeHash['remoteKey']['private'].nil?
                    verifyPrivateKeyHexString(attributeHash['remoteKey']['private'])
                    importPrivateKeyFromHexString(@remoteKey, attributeHash['remoteKey']['private'])
                end
                if !attributeHash['remoteKey']['public'].nil?
                    verifyPublicKeyXYHexString(attributeHash['remoteKey']['public'])
                    importPublicKeyFromXYHexString(@remoteKey, attributeHash['remoteKey']['public'])
                end
            end
        end

        return self
    end


    def toHash()
        hash = {}

        if !@ecCurve.nil?
            hash['ecCurve'] = @ecCurve.nil
        end

        if !@localKey.private_key.nil? || !@localKey.public_key.nil?
            hash['localKey'] = {}

            if !@localKey.private_key.nil?
                hash['localKey']['private'] = exportPrivateKeyAsHexString(@localKey)
            end
            if !@localKey.public_key.nil?
                hash['localKey']['public'] = exportPublicKeyAsXYHexString(@localKey)
            end
        end

        if !@remoteKey.private_key.nil? || !@remoteKey.public_key.nil?
            hash['remoteKey'] = {}

            if !@remoteKey.private_key.nil?
                hash['remoteKey']['private'] = exportPrivateKeyAsHexString(@remoteKey)
            end
            if !@remoteKey.public_key.nil?
                hash['remoteKey']['public'] = exportPublicKeyAsXYHexString(@remoteKey)
            end
        end

        return hash
    end


    # The public key is kept as an EC::Point rather than a key, which
    # limits some functionality in the library. See here:
    #
    #   https://github.com/ruby/openssl/issues/29
    #
    # The below method works around these limitations.

    def ecRealPublicKey(ecKey)
        ecPoint = ecKey.public_key
        publicKey = OpenSSL::PKey::EC.new(ecPoint.group)
        publicKey.public_key = ecPoint

        return publicKey
    end


    def importPrivateKey(key:, format:, keyData:, password: nil)
        if @ecCurve.nil?
            raise ArgumentError.new('ECKeyPair: EC Curve name must be set')
        end
        if !ValueCheck.checkStringConstant(format, ECPrivateKeyFormats)
            raise ArgumentError.new('ECKeyPair: unsupported format')
        end
        if ((format.eql?ECPrivateKeyFormats::PASSWORD_PROTECTED_PEM_STRING) && password.nil?)
            raise ArgumentError.new('ECKeyPair: password not given')
        end

        if key.nil?
            key = OpenSSL::PKey::EC.new(@ecCurve)
        end

        if format.eql?ECPrivateKeyFormats::HEXADECIMAL
            key = importPrivateKeyFromHexString(key, keyData)
        elsif format.eql?ECPrivateKeyFormats::BASE_64_ENCODED_DER
            key = importPrivateKeyFromBase64EncodedDER(key, keyData)
        elsif format.eql?ECPrivateKeyFormats::PEM_STRING
            key = importPrivateKeyFromPEMString(key, keyData)
        elsif format.eql?ECPrivateKeyFormats::PASSWORD_PROTECTED_PEM_STRING
            key = importPrivateKeyFromPasswordProtectedPEMString(key, keyData, password)
        end

        return key
    end


    def importPrivateKeyFromHexString(key, hexExponent)
        key.private_key=OpenSSL::BN.new(hexExponent, 16)

        return key
    end


    def importPrivateKeyFromBase64EncodedDER(key, base64EncodededDER)
        tmpKey = OpenSSL::PKey::EC.new(Base64.decode64(base64EncodededDER))
        key.private_key = tmpKey.private_key

        return key
    end


    def importPrivateKeyFromPEMString(key, pemString)
        tmpKey = OpenSSL::PKey::EC.new(pemString)
        key.private_key = tmpKey.private_key

        return key
    end


    def importPrivateKeyFromPasswordProtectedPEMString(key, passwordProtectedPEMString, password)
        tmpKey = OpenSSL::PKey::EC.new(passwordProtectedPEMString, password)
        key.private_key = tmpKey.private_key

        return key
    end


    def importPublicKey(key:, format:, keyData:, password: nil)
        if @ecCurve.nil?
            raise ArgumentError.new('ECKeyPair: EC Curve name must be set')
        end
        if !ValueCheck.checkStringConstant(format, ECPublicKeyFormats)
            raise ArgumentError.new('ECKeyPair: unsupported format')
        end
        if ((format.eql?ECPublicKeyFormats::PASSWORD_PROTECTED_PEM_STRING) && password.nil?)
            raise ArgumentError.new('ECKeyPair: password not given')
        end

        if key.nil?
            key = OpenSSL::PKey::EC.new(@ecCurve)
        end

        if format.eql?ECPublicKeyFormats::HEXADECIMAL
            key = importPublicKeyFromHexString(key, keyData)
        elsif format.eql?ECPublicKeyFormats::XY_HEXADECIMAL
            key = importPublicKeyFromXYHexString(key, keyData)
        elsif format.eql?ECPublicKeyFormats::BASE_64_ENCODED_DER
            key = importPublicKeyFromBase64EncodedDER(key, keyData)
        elsif format.eql?ECPublicKeyFormats::PEM_STRING
            key = importPublicKeyFromPEMString(key, keyData)
        elsif format.eql?ECPublicKeyFormats::PASSWORD_PROTECTED_PEM_STRING
            key = importPublicKeyFromPasswordProtectedPEMString(key, keyData, password)
        end

        return key
    end


    def importPublicKeyFromHexString(key, hexString)
        pubKeyGroup = OpenSSL::PKey::EC::Group.new(@ecCurve)
        pubKeyBN = OpenSSL::BN.new(hexString, 16)
        key.public_key=OpenSSL::PKey::EC::Point.new(pubKeyGroup, pubKeyBN)

        return key
    end


    def importPublicKeyFromXYHexString(key, xyHexCoordinateString)
        if key.nil?
            key = OpenSSL::PKey::EC.new(@ecCurve)
        end

        index_X = xyHexCoordinateString.index('x')
        index_Y = xyHexCoordinateString.index('y')

        pub_X = xyHexCoordinateString[index_X + 1 .. index_Y - 1]
        pub_Y = xyHexCoordinateString[index_Y + 1 .. -1]

        # EC::Point is poorly documented in Ruby and some affine
        # functions are missing, but from RFC 5480 section 2.2:
        #
        # The first octet of the OCTET STRING indicates whether
        # the key is compressed or uncompressed. The uncompressed
        # form is indicated by 0x04 and the compressed form is
        # indicated by either 0x02 or 0x03 (see 2.3.3 in [SEC1]).
        #
        # The full Y coordinate is used here, so 0x04 is prepended
        # to the string.

        # Add leading zeroes to the coordinates if needed.

        i = 0
        while i < EC_HEX_COORDINATE_LENGTHS[@ecCurve] - pub_X.length do
            pub_X = "0" + pub_X
            i += 1
        end

        i = 0
        while i < EC_HEX_COORDINATE_LENGTHS[@ecCurve] - pub_Y.length do
            pub_Y = "0" + pub_Y
            i += 1
        end

        # Import the key.

        pubKeyGroup = OpenSSL::PKey::EC::Group.new(@ecCurve)
        pubKeyBN = OpenSSL::BN.new("04#{pub_X}#{pub_Y}", 16)
        key.public_key=OpenSSL::PKey::EC::Point.new(pubKeyGroup, pubKeyBN)

        return key
    end


    def importPublicKeyFromBase64EncodedDER(key, base64EncodededDER)
        tmpKey = OpenSSL::PKey::EC.new(Base64.decode64(base64EncodededDER))
        key.public_key = tmpKey.public_key

        return key
    end


    def importPublicKeyFromPEMString(key, pemString)
        tmpKey = OpenSSL::PKey::EC.new(pemString)
        key.public_key = tmpKey.public_key

        return key
    end


    def importPublicKeyFromPasswordProtectedPEMString(key, passwordProtectedPEMString, password)
        tmpKey = OpenSSL::PKey::EC.new(passwordProtectedPEMString, password)
        key.public_key = tmpKey.public_key

        return key
    end


    def exportPrivateKey(key:, format:, password: nil)
        if @ecCurve.nil?
            raise ArgumentError.new('ECKeyPair: EC Curve name must be set')
        end
        if !ValueCheck.checkStringConstant(format, ECPrivateKeyFormats)
            raise ArgumentError.new('ECKeyPair: unsupported format')
        end
        if ((format.eql?ECPrivateKeyFormats::PASSWORD_PROTECTED_PEM_STRING) && password.nil?)
            raise ArgumentError.new('ECKeyPair: password not given')
        end

        if key.nil? || key.private_key.nil?
            raise RuntimeError.new('ECKeyPair: private key must be set to export it')
        end

        export = ""

        if format.eql?ECPrivateKeyFormats::HEXADECIMAL
            export = exportPrivateKeyAsHexString(key)
        elsif format.eql?ECPrivateKeyFormats::BASE_64_ENCODED_DER
            export = exportPrivateKeyAsBase64EncodedDER(key)
        elsif format.eql?ECPrivateKeyFormats::PEM_STRING
            export = exportPrivateKeyAsPEMString(key)
        elsif format.eql?ECPrivateKeyFormats::PASSWORD_PROTECTED_PEM_STRING
            export = exportPrivateKeyAsPasswordProtectedPEMString(key, password)
        end

        return export
    end


    def exportPrivateKeyAsHexString(key)
        return key.private_key.to_bn.to_s(16).downcase
    end


    def exportPrivateKeyAsBase64EncodedDER(key)
        derEncodedPrivateKey = key.to_der()
        return Base64.encode64(derEncodedPrivateKey).gsub("\n", "")
    end


    def exportPrivateKeyAsPEMString(key)
        return key.to_pem()
    end


    def exportPrivateKeyAsPasswordProtectedPEMString(key, password)
        return key.to_pem(OpenSSL::Cipher.new('aes256'), 'password')
    end


    def exportPublicKey(key:, format:, password: nil)
        if @ecCurve.nil?
            raise ArgumentError.new('ECKeyPair: EC Curve name must be set')
        end
        if !ValueCheck.checkStringConstant(format, ECPublicKeyFormats)
            raise ArgumentError.new('ECKeyPair: unsupported format')
        end
        if ((format.eql?ECPublicKeyFormats::PASSWORD_PROTECTED_PEM_STRING) && password.nil?)
            raise ArgumentError.new('ECKeyPair: password not given')
        end

        if key.nil? || key.private_key.nil?
            raise RuntimeError.new('ECKeyPair: private key must be set to export it')
        end

        export = ""

        if format.eql?ECPublicKeyFormats::HEXADECIMAL
            export = exportPublicKeyAsHexString(key)
        elsif format.eql?ECPublicKeyFormats::XY_HEXADECIMAL
            export = exportPublicKeyAsXYHexString(key)
        elsif format.eql?ECPublicKeyFormats::BASE_64_ENCODED_DER
            export = exportPublicKeyAsBase64EncodedDER(key)
        elsif format.eql?ECPublicKeyFormats::PEM_STRING
            export = exportPublicKeyAsPEMString(key)
        elsif format.eql?ECPublicKeyFormats::PASSWORD_PROTECTED_PEM_STRING
            export = exportPublicKeyAsPasswordProtectedPEMString(key, password)
        end

        return export
    end


    def exportPublicKeyAsHexString(key)
        return key.public_key.to_bn.to_s(16)
    end


    def exportPublicKeyAsXYHexString(key)
        formattedPublicKey = key.public_key.to_bn.to_s(16)

        format = formattedPublicKey[0 .. 1]

        if !format.eql?"04"
            return nil
        end

        coordinates = formattedPublicKey[2 .. -1]
        coordinateSize = coordinates.length / 2

        pubX = coordinates[0 .. coordinateSize -1].downcase
        pubY = coordinates[coordinateSize .. -1].downcase

        return "x#{pubX}y#{pubY}"
    end


    def exportPublicKeyAsBase64EncodedDER(key)
        derEncodedPublicKey = ecRealPublicKey(key).to_der()
        return Base64.encode64(derEncodedPublicKey).gsub("\n", "")
    end


    def exportPublicKeyAsPEMString(key)
        return ecRealPublicKey(key).to_pem()
    end


    def exportPublicKeyAsPasswordProtectedPEMString(key, password)
        return ecRealPublicKey(key).to_pem(OpenSSL::Cipher.new('aes256'), password)
    end


    def verifyPrivateKeyHexString(hexString)
        if !hexString.is_a?(String) || /[^0-9a-fA-F]/ =~ hexString
            raise ArgumentError.new('ECDH: private key must be a hex string')
        end
    end


    def verifyPublicKeyXYHexString(xyHexCoordinateString)
        verified = true

        if !xyHexCoordinateString.is_a?(String) || /[^0-9a-fA-Fxy]/ =~ xyHexCoordinateString
            verified = false
        end

        index_X = xyHexCoordinateString.index('x')
        index_Y = xyHexCoordinateString.index('y')

        if index_X != 0 || index_Y < 2
            verified = false
        end

        if xyHexCoordinateString.length - 1 == index_Y
            verified = false
        end

        if !verified
            raise ArgumentError.new('ECKeyPair: public key must be hex X and Y coordinates prepended with \'x\' and \'y\' respectively')
        end
    end

    private :ecRealPublicKey,
            :importPrivateKey,
            :importPrivateKeyFromHexString,
            :importPrivateKeyFromBase64EncodedDER,
            :importPrivateKeyFromPEMString,
            :importPrivateKeyFromPasswordProtectedPEMString,
            :importPublicKey,
            :importPublicKeyFromHexString,
            :importPublicKeyFromXYHexString,
            :importPublicKeyFromBase64EncodedDER,
            :importPublicKeyFromPEMString,
            :importPublicKeyFromPasswordProtectedPEMString,
            :exportPrivateKey,
            :exportPrivateKeyAsHexString,
            :exportPrivateKeyAsBase64EncodedDER,
            :exportPrivateKeyAsPEMString,
            :exportPrivateKeyAsPasswordProtectedPEMString,
            :exportPublicKey,
            :exportPublicKeyAsHexString,
            :exportPublicKeyAsXYHexString,
            :exportPublicKeyAsBase64EncodedDER,
            :exportPublicKeyAsPEMString,
            :exportPublicKeyAsPasswordProtectedPEMString,
            :verifyPrivateKeyHexString,
            :verifyPublicKeyXYHexString
end
