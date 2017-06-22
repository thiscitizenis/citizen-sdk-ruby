class Person

    attr_reader :id,
                :title,
                :firstName,
                :middleName,
                :lastName,
                :gender,
                :dateOfBirth,
                :placeOfBirth,
                :countryNationality,
                :profilePicId,
                :phone,
                :address,
                :addressHistory,
                :entityId

    def intitialize()
        @id                 = nil   # String (alpha-numeric)
        @title              = nil   # String (NameTitles)
        @firstName          = nil   # String (alpha-numeric)
        @middleName         = nil   # String (alpha-numeric)
        @lastName           = nil   # String (alpha-numeric)
        @gender             = nil   # String ('F' or 'M')
        @dateOfBirth        = nil   # String YYYY-MM-DD-T22:00:00.000Z
        @placeOfBirth       = nil   # String (alpha-numeric)
        @countryNationality = nil   # String (CountryName two letters)
        @profilePicId       = nil   # String (alpha-numeric)
        @phone              = nil   # Phone object
        @address            = nil   # Address object
        @addressHistory     = nil   # List of address objects
        @entityId           = nil   # String (alpha-numeric)
    end


    def id=(id)
        if !id.is_a?(String)
            raise ArgumentError.new('Person: id must be a string')
        end
        @id = id.dup()
    end


    def title=(title)
        if !ValueCheck.checkStringConstant(title, NameTitles)
            validVals = ValueCheck.getConstantsAsCommaSeperatedString(NameTitles)
            raise ArgumentError.new("Person: title must be one of #{validVals}")
        end

        @title = title.dup()
    end


    def firstName=(firstName)
        if !firstName.is_a?(String)
            raise ArgumentError.new('Person: first name must be a string')
        end

        @firstName = firstName.dup()
    end


    def middleName=(middleName)
        if !middleName.is_a?(String)
            raise ArgumentError.new('Person: middle name must be a string')
        end

        @middleName = middleName.dup()
    end


    def lastName(lastName)
        if !lastName.is_a?(String)
            raise ArgumentError.new('Person: last name must be a string')
        end

        @lastName = lastName.dup()
    end


    def gender=(gender)
        if !ValueCheck.checkStringConstant(gender, GenderType)
            validVals = ValueCheck.getConstantsAsCommaSeperatedString(NameTitles)
            raise ArgumentError.new("Person: gender must be one of #{validVals}")
        end

        @gender = gender.dup()
    end


    def dateOfBirth=(dateOfBirth)
        if (!dateOfBirth.is_a?Date) && (!dateOfBirth.is_a?String)
            raise ArgumentError.new('Person: date of birth must be a Date object or a string formatted as: YYYY-MM-DD-THH:MM:SS.sssZ')
        end

        if dateOfBirth.is_a?Date

            day   = sprintf("%02d", dateOfBirth.day)
            month = sprintf("%02d", dateOfBirth.month)
            year  = sprintf("%04d", dateOfBirth.year)

            formattedDate = year + "-" + month + "-" + day + "T22:00:00.000Z"

            @dateOfBirth = formattedDate

        else
            if !(/^\d{4}\-\d{2}\-\d{2}T\d{2}\:\d{2}\:\d{2}\.\d{3}Z$/ =~ dateOfBirth)
                raise ArgumentError.new('Person: date of birth string must be formatted as: YYYY-MM-DD-THH:MM:SS.sssZ')
            end

            @dateOfBirth = dateOfBirth.dup()
        end
    end


    def placeOfBirth=(placeOfBirth)
        if !placeOfBirth.is_a?(String)
            raise ArgumentError.new('Person: place of birth must be a string')
        end

        @placeOfBirth = placeOfBirth.dup()
    end


    def countryNationality=(countryNationality)
        if !ValueCheck.checkSymbolAsString(countryNationality, CountryName)
            raise ArgumentError.new('Person: countryNationality must be a ISO-3166 country code string')
        end

        @countryNationality = countryNationality.dup()
    end


    def profilePicId=(profilePicId)
        if !profilePicId.is_a?(String)
            raise ArgumentError.new('Person: profile picture ID must be an alpha-numeric string')
        end

        @profilePicId = profilePicId.dup()
    end


    def phone=(phone)
        if !phone.is_a?(Phone)
            raise ArgumentError.new('Person: phone must be a Phone object')
        end

        @phone = phone.dup()
    end


    def address=(address)
        if !address.is_a?(Address)
            raise ArgumentError.new('Person: address must be an Address object')
        end

        @address = address.dup()
    end


    def addressHistory=(addressHistory)
        if !addressHistory.is_a?(Array)
            raise ArgumentError.new('Person: addressHistory must be an array of Address objects')
        end
        addressHistory.each do | address |
            if !address.is_a?(Address)
                raise ArgumentError.new('Person: addressHistory must be an array of Address objects')
            end
        end

        @addressHistory = addressHistory.dup()
    end


    def entityId=(entityId)
        if !entityId.is_a?(String)
            raise ArgumentError.new('Person: entity ID must be an alpha-numeric string')
        end

        @entityId = entityId.dup()
    end


    def fromHash(attributeHash)
        if !attributeHash.nil?
            @id                 = attributeHash['id']
            @title              = attributeHash['title']
            @firstName          = attributeHash['firstName']
            @middleName         = attributeHash['middleName']
            @lastName           = attributeHash['lastName']
            @gender             = attributeHash['gender']
            @dateOfBirth        = attributeHash['dateOfBirth']
            @placeOfBirth       = attributeHash['placeOfBirth']
            @countryNationality = attributeHash['countryNationality']
            @profilePicId       = attributeHash['profilePicId']
            @entityId           = attributeHash['entityId']

            if !attributeHash['phone'].nil?
                @phone    = Phone.new().fromHash(attributeHash['phone'])
            end
            if !attributeHash['address'].nil?
                @address  = Address.new().fromHash(attributeHash['address'])
            end

            if !attributeHash['addressHistory'].nil?
                @addressHistory = []

                attributeHash['addressHistory'].each do | address |
                    @addressHistory.push(Address.new().fromHash(address));
                end
            end
        end

        return self
    end


    def toHash()
        hash = {}

        self.instance_variables.each do | var |

            if !self.instance_variable_get(var).nil?
                key = var.to_s.delete("@")

                if key.eql?('phone')

                    hash[key] = @phone.toHash()

                elsif key.eql?('address')

                    hash[key] = @address.toHash()

                elsif key.eql?('addressHistory')

                    hash[key] = []
                    @addressHistory.each do | address |
                        hash[key].push(address.toHash())
                    end

                else

                    hash[key] = self.instance_variable_get(var)
                end
            end
        end

        return hash
    end


    def to_s()
        return self.toHash().to_s()
    end
end
