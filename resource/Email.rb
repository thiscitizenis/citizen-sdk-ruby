class Email

    attr_reader :encryptedEmail, 
                :isPrimary,
                :isEntityEmail,
                :isEntityAdmin


    def initialize()
        @encryptedEmail = nil     # String (alpha-numeric)
        @isPrimary      = false   # Boolean
        @isEntityEmail  = false   # Boolean
        @isEntityAdmin  = false   # Boolean
    end


    def encryptedEmail=(encryptedEmail)
        if !encryptedEmail.is_a?(String)
            raise ArgumentError.new('Email: encryptedEmail must be a string')
        end
        @encryptedEmail = encryptedEmail.dup()
    end


    def isPrimary=(isPrimary)
        if !isPrimary.is_a?(TrueClass) && !isPrimary.is_a?(FalseClass)
            raise ArgumentError.new('Email: isPrimary must be a boolean')
        end
        @isPrimary = isPrimary.dup()
    end


    def isEntityEmail=(isEntityEmail)
        if !isEntityEmail.is_a?(TrueClass) && !isEntityEmail.is_a?(FalseClass)
            raise ArgumentError.new('Email: isEntityEmail must be a boolean')
        end
        @isEntityEmail = isEntityEmail.dup()
    end


    def isEntityAdmin=(isEntityAdmin)
        if !isEntityAdmin.is_a?(TrueClass) && !isEntityAdmin.is_a?(FalseClass)
            raise ArgumentError.new('Email: isEntityAdmin must be a boolean')
        end
        @isEntityAdmin = isEntityAdmin.dup()
    end


    def fromHash(attributeHash)
        if !attributeHash.nil?
            @encryptedEmail = attributeHash['encryptedEmail']
            @isPrimary      = attributeHash['isPrimary']
            @isEntityEmail  = attributeHash['isEntityEmail']
            @isEntityAdmin  = attributeHash['isEntityAdmin']
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
