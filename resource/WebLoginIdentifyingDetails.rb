class WebLoginIdentifyingDetails

    attr_reader :nonce, 
                :username,
                :browserECDHPublicKey


    def initialize()
        @nonce                = nil   # String (alpha-numeric)
        @username             = nil   # String (email address)
        @browserECDHPublicKey = nil   # String (alpha-numeric) 
    end


    def nonce=(nonce)
        if !nonce.is_a?(String)
            raise ArgumentError.new('WebLoginIdentifyingDetails: nonce must be a string')
        end
        @nonce = nonce.dup()
    end


    def username=(username)
        if !ValueCheck.checkEmailAddress(username)
            raise ArgumentError.new('WebLoginIdentifyingDetails: must be a string email address')
        end
        @username = username.dup()
    end


    def browserECDHPublicKey=(browserECDHPublicKey)
        if !browserECDHPublicKey.is_a?(String)
            raise ArgumentError.new('WebLoginIdentifyingDetails: browserECDHPublicKey must be a string')
        end
        @browserECDHPublicKey = browserECDHPublicKey.dup()
    end


    def fromHash(attributeHash)
        if !attributeHash.nil?
            @nonce                = attributeHash['nonce']
            @username             = attributeHash['username']
            @browserECDHPublicKey = attributeHash['browserECDHPublicKey']
        end

        return self
    end


    def toHash()
        hash = {}

        self.instance_variables.each do | var |

            if !self.instance_variable_get(var).nil?
                key = var.to_s.delete("@")
                hash[key] = self.instance_variable_get(var)
            end
        end

        return hash
    end


    def to_s()
        return self.toHash().to_s()
    end
end
