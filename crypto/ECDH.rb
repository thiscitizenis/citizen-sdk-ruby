class ECDH < ECKeyPair

    def initialize()
        @ecCurve   = ECCurves::P384   # ECCurves string
        @localKey  = nil              # OpenSSL::PKey::EC
        @remoteKey = nil              # OpenSSL::PKey::EC
    end


    def getSharedSecret()
        if @localKey.nil? || @localKey.private_key.nil?
            raise RuntimeError.new('ECDH: local private key must be set to generate shared secret')
        end
        if @remoteKey.nil? || @remoteKey.public_key.nil?
            raise RuntimeError.new('ECDH: remote public key must be set to generate shared secret')
        end

        ecdhSecret = @localKey.dh_compute_key(@remoteKey.public_key).unpack('H*').join("")

        return OpenSSL::Digest::SHA256.new.base64digest(ecdhSecret)
    end
end
