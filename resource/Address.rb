class Address

    attr_reader :id,
                :personId,
                :addressLine1,
                :addressLine2,
                :addressLine3,
                :city,
                :state,
                :countryName,
                :addressType,
                :postCode,
                :validTo,
                :validFrom,
                :confirmCode,
                :confirmedByCode,
                :addressLatitude,
                :addressLongitude,
                :confirmedByLocation,
                :confirmedLatitude,
                :confirmedLongitude


    def initialize()
        @id                  = nil   # String (alpha-numeric)
        @personId            = nil   # String (alpha-numeric)
        @addressLine1        = nil   # String (alpha-numeric)
        @addressLine2        = nil   # String (alpha-numeric)
        @addressLine3        = nil   # String (alpha-numeric)
        @city                = nil   # String (alpha-numeric)
        @state               = nil   # String (alpha-numeric)
        @countryName         = nil   # String (CountryName two letters)
        @addressType         = nil   # String (AddressType)
        @postCode            = nil   # String (alpha-numeric)
        @validTo             = nil   # String (DateTime)
        @validFrom           = nil   # String (DateTime)
        @confirmCode         = nil   # String (alpha-numeric)
        @confirmedByCode     = nil   # Boolean
        @addressLatitude     = nil   # String (alpha-numeric)
        @addressLongitude    = nil   # String (alpha-numeric)
        @confirmedByLocation = nil   # Boolean
        @confirmedLatitude   = nil   # String (alpha-numeric)
        @confirmedLongitude  = nil   # String (alpha-numeric)
    end


    def id=(id)
        if !id.is_a?(String)
            raise ArgumentError.new('Address: ID must be a string')
        end
        @id = id.dup()
    end


    def personId=(personId)
        if !personId.is_a?(String)
            raise ArgumentError.new('Address: person ID must be a string')
        end
        @personId = personId.dup()
    end


    def addressLine1=(addressLine1)
        if !addressLine1.is_a?(String)
            raise ArgumentError.new('Address: address line 1 must be a string')
        end
        @addressLine1 = addressLine1.dup()
    end


    def addressLine2=(addressLine2)
        if !addressLine2.is_a?(String)
            raise ArgumentError.new('Address: address line 2 must be a string')
        end
        @addressLine2 = addressLine2.dup()
    end


    def addressLine3=(addressLine3)
        if !addressLine3.is_a?(String)
            raise ArgumentError.new('Address: address line 3 must be a string')
        end
        @addressLine3 = addressLine3.dup()
    end


    def city=(city)
        if !city.is_a?(String)
            raise ArgumentError.new('Address: city must be a string')
        end
        @city = city.dup()
    end


    def state=(state)
        if !state.is_a?(String)
            raise ArgumentError.new('Address: state must be a string')
        end
        @state = state.dup()
    end


    def countryName=(countryName)
        if !ValueCheck.checkSymbolAsString(countryName, CountryName)
            raise ArgumentError.new('Address: country name must be a ISO-3166 country code string')
        end
        @countryName = countryName.dup()
    end


    def addressType=(addressType)
        if !ValueCheck.checkStringConstant(addressType, AddressType)
            raise ArgumentError.new('Address: address type must be an AddressType string')
        end

        @addressType = addressType.dup()
    end


    def postCode=(postCode)
        if !postCode.is_a?(String)
            raise ArgumentError.new('Address: post code must be a string')
        end
        @postCode = postCode.dup()
    end


    def validTo=(validTo)
        if !validTo.is_a?(String)
            raise ArgumentError.new('Address: valid to must be a string')
        end
        @validTo = validTo.dup()
    end


    def validFrom=(validFrom)
        if !validFrom.is_a?(String)
            raise ArgumentError.new('Address: valid from must be a string')
        end
        @validFrom = validFrom.dup()
    end


    def confirmCode=(confirmCode)
        if !confirmCode.is_a?(String)
            raise ArgumentError.new('Address: confirm code must be a string')
        end
        @confirmCode = confirmCode.dup()
    end


    def confirmedByCode=(confirmedByCode)
        if !confirmedByCode.is_a?(TrueClass) && !confirmedByCode.is_a?(FalseClass)
            raise ArgumentError.new('Address: confirmed by code must be a boolean')
        end
        @confirmedByCode = confirmedByCode.dup()
    end


    def addressLatitude=(addressLatitude)
        if !addressLatitude.is_a?(String)
            raise ArgumentError.new('Address: address latitude must be a string')
        end
        @addressLatitude = addressLatitude.dup()
    end


    def addressLongitude=(addressLongitude)
        if !addressLongitude.is_a?(String)
            raise ArgumentError.new('Address: address longitude must be a string')
        end
        @addressLongitude = addressLongitude.dup()
    end


    def confirmedByLocation=(confirmedByLocation)
        if !confirmedByLocation.is_a?(TrueClass) && !confirmedByLocation.is_a?(FalseClass)
            raise ArgumentError.new('Address: confirmed by location must be a boolean')
        end
        @confirmedByLocation = confirmedByLocation.dup()
    end


    def confirmedLatitude=(confirmedLatitude)
        if !confirmedLatitude.is_a?(String)
            raise ArgumentError.new('Address: confirmed latitide must be a string')
        end
        @confirmedLatitude = confirmedLatitude.dup()
    end


    def confirmedLongitude=(confirmedLongitude)
        if !confirmedLongitude.is_a?(String)
            raise ArgumentError.new('Address: confirmed logitude must be a string')
        end
        @confirmedLongitude = confirmedLongitude.dup()
    end


    def fromHash(attributeHash)
        if !attributeHash.nil?
            @id                  = attributeHash['id']
            @personId            = attributeHash['personId']
            @addressLine1        = attributeHash['addressLine1']
            @addressLine2        = attributeHash['addressLine2']
            @addressLine3        = attributeHash['addressLine3']
            @city                = attributeHash['city']
            @state               = attributeHash['state']
            @countryName         = attributeHash['countryName']
            @addressType         = attributeHash['addressType']
            @postCode            = attributeHash['postCode']
            @validTo             = attributeHash['validTo']
            @validFrom           = attributeHash['validFrom']
            @confirmCode         = attributeHash['confirmCode']
            @confirmedByCode     = attributeHash['confirmedByCode']
            @addressLatitude     = attributeHash['addressLatitude']
            @addressLongitude    = attributeHash['addressLongitude']
            @confirmedByLocation = attributeHash['confirmedByLocation']
            @confirmedLatitude   = attributeHash['confirmedLatitude']
            @confirmedLongitude  = attributeHash['confirmedLongitude']
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
