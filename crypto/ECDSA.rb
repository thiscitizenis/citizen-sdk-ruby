class ECDSA < ECKeyPair

    def sign(data)
        if @localKey.nil? || @localKey.private_key.nil?
            raise RuntimeError.new('ECDSA: local private key must be set to sign data')
        end

        signatureBytes = @localKey.dsa_sign_asn1(OpenSSL::Digest::SHA256.new.digest(data))

        return Base64.encode64(signatureBytes).gsub("\n", "")
    end


    def verify(data, signatureBase64)
        if @remoteKey.nil? || @remoteKey.public_key.nil?
            raise RuntimeError.new('ECDSA: remote public key must be set to verify data')
        end

        signatureBytes = Base64.decode64(signatureBase64)

        return @remoteKey.dsa_verify_asn1(OpenSSL::Digest::SHA256.new.digest(data), signatureBytes)
    end
end
