class LoginTransaction

    attr_reader :id, 
                :username,
                :token


    def initialize()
        @id       = nil   # String (alpha-numeric)
        @username = nil   # String (email address)
        @token    = nil   # String (alpha-numeric)
    end


    def id=(id)
        if !id.is_a?(String)
            raise ArgumentError.new('LoginTransaction: id must be a string')
        end
        @id = id.dup()
    end


    def username=(username)
        if !ValueCheck.checkEmailAddress(username)
            raise ArgumentError.new('LoginTransaction: username must be a string email address')
        end
        @username = username.dup()
    end


    def token=(token)
        if !token.is_a?(String)
            raise ArgumentError.new('LoginTransaction: token must be a string')
        end
        @token = token.dup()
    end


    def generateToken()
        @token = Random.getRandomString(64)
    end


    def getDataToSign()
        if username.nil? || token.nil?
            raise ArgumentError.new('LoginTransaction: username and token must be set to get data to sign')
        end
        return username + token
    end


    def fromHash(attributeHash)
        if !attributeHash.nil?
            @id       = attributeHash['id']
            @username = attributeHash['username']
            @token    = attributeHash['token']
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
