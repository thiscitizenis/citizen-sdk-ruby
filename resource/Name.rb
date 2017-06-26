class Name

    attr_reader :title,
                :firstName,
                :lastName,
                :middleName,
                :gender


    def initialize()
        @title      = nil   # String (NameTitles) 
        @firstName  = nil   # String (alpha-numeric)
        @lastName   = nil   # String (alpha-numeric)
        @middleName = nil   # String (alpha-numeric)
        @gender     = nil   # String (GenderType)
    end


    def title=(title)
        if !ValueCheck.checkStringConstant(title, NameTitles)
            validVals = ValueCheck.getConstantsAsCommaSeperatedString(NameTitles)
            raise ArgumentError.new("Name: title must be one of #{validVals}")
        end
        @title = title.dup()
    end


    def firstName=(firstName)
        if !firstName.is_a?(String)
            raise ArgumentError.new('Name: first name must be a string')
        end
        @firstName = firstName.dup()
    end


    def lastName=(lastName)
        if !lastName.is_a?(String)
            raise ArgumentError.new('Name: last name must be a string')
        end
        @lastName = lastName.dup()
    end


    def middleName=(middleName)
        if !middleName.is_a?(String)
            raise ArgumentError.new('Name: middle name must be a string')
        end
        @middleName = middleName.dup()
    end


    def gender=(gender)
        if !ValueCheck.checkStringConstant(gender, GenderType)
            validVals = ValueCheck.getConstantsAsCommaSeperatedString(GenderType)
            raise ArgumentError.new("Name: gender must be one of #{validVals}")
        end
        @gender = gender.dup()
    end


    def fromHash(attributeHash)
        if !attributeHash.nil?
            @title      = attributeHash['title']
            @firstName  = attributeHash['firstName']
            @lastName   = attributeHash['lastName']
            @middleName = attributeHash['middleName']
            @gender     = attributeHash['gender']
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
