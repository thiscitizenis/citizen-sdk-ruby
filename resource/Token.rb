class Token

    attr_reader :id,
                :tokenStatus,
                :userEmail,
                :hashedUserEmail,
                :requesterEmail,
                :hashedRequesterEmail,
                :access,
                :durationType,
                :duration,
                :expiryDate,
                :creationDate,
                :metaData


    def initialize()
        @id                   = nil   # String (alpha-numeric)
        @tokenStatus          = nil   # String (TokenStatus)
        @userEmail            = nil   # String (email address)
        @hashedUserEmail      = nil   # String (alpha-numeric)
        @requesterEmail       = nil   # String (email address)
        @hashedRequesterEmail = nil   # String (alpha-numeric)
        @access               = nil   # Integer (AccessType)
        @durationType         = nil   # String (TokenDurationType)
        @duration             = nil   # Integer (TokenDurationType units)
        @expiryDate           = nil   # Integer (UNIX timestamp)
        @creationDate         = nil   # Integer (UNIX timestamp)
        @metaData             = nil   # Hash (PropertyType -> val)
    end


    def id=(id)
        if !id.is_a?(String)
            raise ArgumentError.new('Token: id must be a string')
        end
        @id = id.dup()
    end


    def tokenStatus=(tokenStatus)
        if !ValueCheck.checkStringConstant(tokenStatus, TokenStatus)
            raise ArgumentError.new('Token: tokenStatus must be a TokenStatus string')
        end
        @tokenStatus = tokenStatus.dup()
    end
        

    def userEmail=(userEmail)
        if !ValueCheck.checkEmailAddress(userEmail)
            raise ArgumentError.new('Token: userEmail must be a string email address')
        end
        @userEmail = userEmail.dup()
    end
    

    def hashedUserEmail=(hashedUserEmail)
        if !hashedUserEmail.is_a?(String)
            raise ArgumentError.new('Token: hashedUserEmail must be a string')
        end
        @hashedUserEmail = hashedUserEmail.dup()
    end


    def requesterEmail=(requesterEmail)
        if !ValueCheck.checkEmailAddress(requesterEmail)
            raise ArgumentError.new('Token: requesterEmail must be a string email address')
        end
        @requesterEmail = requesterEmail.dup()
    end


    def hashedRequesterEmail=(hashedRequesterEmail)
        if !hashedRequesterEmail.is_a?(String)
            raise ArgumentError.new('Token: hashedRequesterEmail must be a string')
        end
        @hashedRequesterEmail = hashedRequesterEmail.dup()
    end


    def access=(access)
        if !access.is_a?(Fixnum)
            raise ArgumentError.new('Token: access must be an integer')
        end
        if !TokenAccess.verify(access)
            raise ArgumentError.new('Token: invalid access type')
        end
        @access = access
    end


    def durationType=(durationType)
        if !ValueCheck.checkStringConstant(durationType, TokenDurationType)
            raise ArgumentError.new('Token: durationType must be a TokenDurationType string')
        end
        @durationType = durationType.dup()
    end


    def duration=(duration)
        if !duration.is_a?(Fixnum) || duration < 0
            raise ArgumentError.new('Token: duration: must be a positive integer')
        end
        @duration = duration
    end


    def expiryDate=(expiryDate)
        if !expiryDate.is_a?(Fixnum) || expiryDate < 0
            raise ArgumentError.new('Token: expiryDate must be a positive integer')
        end
        @expiryDate = expiryDate
    end


    def creationDate=(creationDate)
        if !creationDate.is_a?(Fixnum) || creationDate < 0
            raise ArgumentError.new('Token: creationDate must be a positive integer')
        end
        @creationDate = creationDate
    end


    def metaData=(metaData)
        if !metaData.is_a?(Hash)
            raise ArgumentError.new('Token: metaData must be a hash keyed by PropertyType strings')
        end

        metaData.each do | key, value |
            if !ValueCheck.checkStringConstant(key, PropertyType)
                raise ArgumentError.new('Token: metaData must be a hash keyed by PropertyType strings')
            end
        end

        @metaData = metaData.dup()
    end
            

    def fromHash(attributeHash)
        if !attributeHash.nil?
            @id                   = attributeHash['id']
            @tokenStatus          = attributeHash['tokenStatus']
            @userEmail            = attributeHash['userEmail']
            @hashedUserEmail      = attributeHash['hashedUserEmail']
            @requesterEmail       = attributeHash['requesterEmail']
            @hashedRequesterEmail = attributeHash['hashedRequesterEmail']
            @access               = attributeHash['access']
            @durationType         = attributeHash['durationType']
            @duration             = attributeHash['duration']
            @expiryDate           = attributeHash['expiryDate']
            @creationDate         = attributeHash['creationDate']
            @metaData             = attributeHash['metaData']
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


    def getProperty(propertyType)
        if !ValueCheck.checkStringConstant(propertyType, PropertyType)
            raise ArgumentError.new('Token: propertyType must be a PropertyType string')
        end

        if @metaData.nil?
            return nil
        end

        return @metaData[propertyType]
    end


    def setProperty(propertyType, propertyValue)
        if !ValueCheck.checkStringConstant(propertyType, PropertyType)
            raise ArgumentError.new('Token: propertyType must be a PropertyType string')
        end

        if @metaData.nil?
            @metaData = {}
        end

        @metaData[propertyType] = propertyValue
    end


    def deleteProperty(propertyType)
        if !ValueCheck.checkStringConstant(propertyType, PropertyType)
            raise ArgumentError.new('Token: propertyType must be a PropertyType string')
        end

        if @metaData.nil?
            return
        end

        metaData.tap do | t | t.delete(propertyType) end
    end


    # Items in the @metaData hash may be encrypted and more
    # may be added, so they stored in a hash rather than an
    # object. 
    #
    # The following convenience methods may be helpful when 
    # accessing the more commonly used fields in the hash.

    def getFirstName()
        return @metaData[PropertyType::FIRST_NAME]
    end

 
    def setFirstName(firstName)
        if !firstName.is_a?(String)
            raise ArgumentError.new('Token: first name must be a string')
        end

        @metaData[PropertyType::FIRST_NAME] = firstName
    end


    def getMiddleName()
        return @metaData[PropertyType::MIDDLE_NAME]
    end


    def setMiddleName(middleName)
        if !middleName.is_a?(String)
            raise ArgumentError.new('Token: middle name must be a string')
        end

        @metaData[PropertyType::MIDDLE_NAME] = middleName
    end


    def getLastName()
        return @metaData[PropertyType::LAST_NAME]
    end


    def setLastName(lastName)
        if !lastName.is_a?(String)
            raise ArgumentError.new('Token: last name must be a string')
        end

        @metaData[PropertyType::LAST_NAME] = lastName
    end


    def getTitle()
        return @metaData[PropertyType::TITLE]
    end


    def setTitle(title)
        if !ValueCheck.checkStringConstant(title, NameTitles)
            validVals = ValueCheck.getConstantsAsCommaSeperatedString(NameTitles)
            raise ArgumentError.new("Token: title must be one of #{validVals}")
        end

        @metaData[PropertyType::TITLE] = title
    end


    def getDob()
        if @metaData[PropertyType::DOB].nil?
            return nil
        end
        if !@metaData[PropertyType::DOB].is_a?(String)
            raise RuntimeError.new('Token: unable to parse date into Date object')
        end
        if !(/^\d{4}\-\d{2}\-\d{2}T/ =~ @metaData[PropertyType::DOB])
            puts(@metaData[PropertyType::DOB])
            raise RuntimeError.new('Token: unable to parse date into Date object')
        end

        date = @metaData[PropertyType::DOB].dup().gsub(/T.+/, '')

        dateComponents = date.split('-')

        return Date.new(dateComponents[0].to_i(), dateComponents[1].to_i(), dateComponents[2].to_i())
    end


    def setDob(date)
        if !date.is_a?Date
            raise ArgumentError.new('Token: date of birth must be a Date object')
        end

        day   = sprintf("%02d", date.day)
        month = sprintf("%02d", date.month)
        year  = sprintf("%04d", date.year)

        formattedDate = year + "-" + month + "-" + day + "T22:00:00.000Z"

        @metaData[PropertyType::DOB] = formattedDate
    end


    def getPhone()
        return @metaData[PropertyType::PHONE]
    end


    def setPhone(countryCode, phoneNumber)
        if !ValueCheck.checkStringConstant(countryCode, CountryCode)
            raise ArgumentError.new('Token: phone country code must be a CountryCode string')
        end
        if /[^0-9]/ =~ phoneNumber
            raise ArgumentError.new('Token: phone number must be a string of digits')
        end

        @metaData[PropertyType::PHONE] = "+" + countryCode + phoneNumber
    end


    def getHomeAddress1()
        return @metaData[PropertyType::HOME_ADDRESS1]
    end


    def setHomeAddress1(homeAddress1)
        if !homeAddress1.is_a?(String)
            raise ArgumentError.new('Token: home address 1 must be a string')
        end

        @metaData[PropertyType::HOME_ADDRESS1] = homeAddress1
    end


    def getHomeAddress2()
        return @metaData[PropertyType::HOME_ADDRESS2]
    end


    def setHomeAddress2(homeAddress2)
        if !homeAddress2.is_a?(String)
            raise ArgumentError.new('Token: home address 2 must be a string')
        end

        @metaData[PropertyType::HOME_ADDRESS2] = homeAddress2
    end


    def getHomeAddress3()
        return @metaData[PropertyType::HOME_ADDRESS3]
    end


    def setHomeAddress3(homeAddress3)
        if !homeAddress3.is_a?(String)
            raise ArgumentError.new('Token: home address 3 must be a string')
        end

        @metaData[PropertyType::HOME_ADDRESS3] = homeAddress3
    end


    def getHomeCity()
        return @metaData[PropertyType::HOME_CITY]
    end


    def setHomeCity(homeCity)
        if !homeCity.is_a?(String)
            raise ArgumentError.new('Token: home city must be a string')
        end

        @metaData[PropertyType::HOME_CITY] = homeCity
    end


    def getHomeState()
        return @metaData[PropertyType::HOME_STATE]
    end


    def setHomeState(homeState)
        if !homeState.is_a?(String)
            raise ArgumentError.new('Token: home state must be a string')
        end

        @metaData[PropertyType::HOME_STATE] = homeState
    end


    def getHomePostCode()
        return @metaData[PropertyType::HOME_POST_CODE]
    end


    def setHomePostCode(homePostCode)
        if !homePostCode.is_a?(String)
            raise ArgumentError.new('Token: home post code must be a string')
        end

        @metaData[PropertyType::HOME_POST_CODE] = homePostCode
    end


    def getHomeCountryCode()
        return @metaData[PropertyType::HOME_COUNTRY_CODE]
    end


    def setHomeCountryCode(homeCountryCode)
        if !ValueCheck.checkSymbolAsString(homeCountryCode, CountryName)
            raise ArgumentError.new('Token: home country code must be a ISO-3166 country code string')
        end

        @metaData[PropertyType::HOME_COUNTRY_CODE] = homeCountryCode
    end


    def getPob()
        return @metaData[PropertyType::POB]
    end


    def setPob(pob)
        if !pob.is_a?(String)
            raise ArgumentError.new('Token: place of birth must be a string')
        end

        @metaData[PropertyType::POB] = pob
    end


    def getNationality()
        return @metaData[PropertyType::NATIONALITY]
    end


    def setNationality(nationality)
        if !ValueCheck.checkSymbolAsString(nationality, CountryName)
            raise ArgumentError.new('Token: nationality must be a ISO-3166 country code string')
        end

        @metaData[PropertyType::NATIONALITY] = nationality
    end
end
