class Phone

    attr_reader :id,
                :personId,
                :countryCode,
                :phoneNumber,
                :smsConfirmCode,
                :smsConfirmTime,
                :smsConfirmed,
                :phoneType,


    def initialize()
        @id             = nil   # String (alpha-numeric)
        @personId       = nil   # String (alpha-numeric)
        @countryCode    = nil   # String (CountryCode two letters)
        @phoneNumber    = nil   # String (0-9)
        @smsConfirmCode = nil   # String (alpha-numeric)
        @smsConfirmTime = nil   # String (DateTime)
        @smsConfirmed   = nil   # Boolean
        @phoneType      = nil   # String (PhoneType)
    end


    def id=(id)
        if !id.is_a?(String)
            raise ArgumentError.new('Phone: id must be a string')
        end
        @id = id.dup()
    end


    def personId=(personId)
        if !personId.is_a?(String)
            raise ArgumentError.new('Phone: person ID must be a string')
        end
        @personId = personId.dup()
    end


    def countryCode=(countryCode)
        if !ValueCheck.checkSymbolAsString(countryCode, CountryCode)
            raise ArgumentError.new('Person: phone country code must be a ISO-3166 country code string')
        end
        if !@phoneNumber.nil?
            @phoneNumber = "+" + CountryCode.const_get(@countryCode) + phoneNumber.dup()
        end
        @countryCode = countryCode.dup()
    end


    def phoneNumber=(phoneNumber)
        if (!phoneNumber.is_a?(String)) || (/[^0-9]/ =~ phoneNumber)
            raise ArgumentError.new('Phone: phone number must be a string containing digits 0 to 9')
        end
        if !@countryCode.nil?
            @phoneNumber = "+" + CountryCode.const_get(@countryCode) + phoneNumber.dup()
        else
            @phoneNumber = phoneNumber.dup()
        end
    end


    def smsConfirmCode=(smsConfirmCode)
        if !smsConfirmCode.is_a?(String)
            raise ArgumentError.new('Phone: SMS confirm code must be a string')
        end
        @smsConfirmCode = smsConfirmCode.dup()
    end


    def smsConfirmTime=(smsConfirmTime)
        if !smsConfirmTime.is_a?(String)
            raise ArgumentError.new('Phone: SMS confirm time must be a string')
        end
        @smsConfirmTime = smsConfirmTime.dup()
    end 


    def smsConfirmed=(smsConfirmed)
        if !smsConfirmed.is_a?(TrueClass) && !smsConfirmed.is_a?(FalseClass)
            raise ArgumentError.new('Phone: SMS confirmed must be a boolean')
        end
        @smsConfirmed = smsConfirmed.dup()
    end


    def phoneType=(phoneType)
        if !ValueCheck.checkStringConstant(phoneType, PhoneType)
            validVals = ValueCheck.getConstantsAsCommaSeperatedString(PhoneType)
            raise ArgumentError.new("Phone: phone type must be one of #{validVals}")
        end
        @phoneType = phoneType.dup()
    end


    def fromHash(attributeHash)
        if !attributeHash.nil?
            @id             = attributeHash['id']
            @personId       = attributeHash['personId']
            @countryCode    = attributeHash['countryCode']
            @phoneNumber    = attributeHash['phoneNumber']
            @smsConfirmCode = attributeHash['smsConfirmCode']
            @smsConfirmTime = attributeHash['smsConfirmTime']
            @smsConfirmed   = attributeHash['smsConfirmed']
            @phoneType      = attributeHash['phoneType']
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
