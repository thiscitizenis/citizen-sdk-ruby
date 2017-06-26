class WebLoginSessionDetails

    attr_reader :username,
                :apiKey,
                :sessionNonce,
                :sessionKey


    def initialize()
        @username     = nil   # String (email address)
        @apiKey       = nil   # String (alpha-numeric)
        @sessionNonce = nil   # String (alpha-numeric)
        @sessionKey   = nil   # String (alpha-numeric)
      
    end


    def username=(username)
        if !ValueCheck.checkEmailAddress(username)
            raise ArgumentError.new('WebLoginSessionDetails: username must be a string email address')
        end
        @username = username.dup()
    end


    def apiKey=(apiKey)
        if !apiKey.is_a?(String)
            raise ArgumentError.new('WebLoginSessionDetails: apiKey must be a string')
        end
        @apiKey = apiKey.dup()
    end


    def sessionNonce=(sessionNonce)
        if !sessionNonce.is_a?(String)
            raise ArgumentError.new('WebLoginSessionDetails: sessionNonce must be a string')
        end
        @sessionNonce = sessionNonce.dup()
    end


    def sessionKey=(sessionKey)
        if !sessionKey.is_a?(String)
            raise ArgumentError.new('WebLoginSessionDetails: sessionKey must be a string')
        end
        @sessionKey = sessionKey.dup()
    end


    def fromHash(attributeHash)
        if !attributeHash.nil?
            @username     = attributeHash['username']
            @apiKey       = attributeHash['apiKey']
            @sessionNonce = attributeHash['sessionNonce']
            @sessionKey   = attributeHash['sessionKey']
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
