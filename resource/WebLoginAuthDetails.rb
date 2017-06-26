class WebLoginAuthDetails

    attr_reader :apiKey,
                :phonePubKey


    def initialize()
        @apiKey      = nil   # String (alpha-numeric)
        @phonePubKey = nil   # String (alpha-numeric)
    end


    def apiKey=(apiKey)
        if !apiKey.is_a?(String)
            raise ArgumentError.new('WebLoginAuthDetails: apiKey must be a string')
        end
        @apiKey = apiKey.dup()
    end


    def phonePubKey=(phonePubKey)
        if !phonePubKey.is_a?(String)
            raise ArgumentError.new('WebLoginAuthDetails: phonePubKey must be a string')
        end
        @phonePubKey = phonePubKey.dup()
    end


    def fromHash(attributeHash)
        if !attributeHash.nil?
            @apiKey      = attributeHash['apiKey']
            @phonePubKey = attributeHash['phonePubKey']
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
