class User

    attr_reader :id,
                :primaryEmail,
                :username,
                :password,
                :passwordTemporary,
                :passPhrase,
                :mnemonicCode,
                :apiKey,
                :personId,
                :authPublicKey,
                :publicKey,
                :notificationsToken,
                :entityEmail,
                :emails


    def intitialize()
        @id                 = nil   # String (alpha-numeric)
        @primaryEmail       = nil   # String (email address)
        @username           = nil   # String (alpha-numeric)
        @password           = nil   # String (alpha-numeric)
        @passwordTemporary  = nil   # Boolean
        @passPhrase         = nil   # String (alpha-numeric)
        @mnemonicCode       = nil   # String (alpha-numeric)
        @apiKey             = nil   # String (alpha-numeric)
        @personId           = nil   # String (alpha-numeric)
        @authPublicKey      = nil   # String (alpha-numeric)
        @publicKey          = nil   # String (alpha-numeric)
        @notificationsToken = nil   # String (alpha-numeric)
        @entityEmail        = nil   # String (email address)
        @emails             = nil   # Array of Email objects
    end


    def id=(id)
        if !id.is_a?(String)
            raise ArgumentError.new('User: id must be a string')
        end
        @id = id.dup()
    end


    def primaryEmail=(primaryEmail)
        if !ValueCheck.checkEmailAddress(primaryEmail)
            raise ArgumentError.new('User: primary email must be a string email address')
        end
        @primaryEmail = primaryEmail.dup()
    end


    def username=(username)
        if !username.is_a?(String)
            raise ArgumentError.new('User: username must be a string')
        end
        @username = username.dup()
    end


    def password=(password)
        if !password.is_a?(String)
            raise ArgumentError.new('User: password must be a string')
        end
        @password = password.dup()
    end


    def passwordTemporary=(passwordTemporary)
        if !passwordTemporary.is_a?(TrueClass) && !passwordTemporary.is_a?(FalseClass)
            raise ArgumentError.new('User: passwordTemporary must be a boolean')
        end
        @passwordTemporary = passwordTemporary.dup()
    end


    def passPhrase=(passPhrase)
        if !passPhrase.is_a?(String)
            raise ArgumentError.new('User: passPhrase must be a string')
        end
        @passPhrase = passPhrase.dup()
    end


    def mnemonicCode=(mnemonicCode)
        if !mnemonicCode.is_a?(String)
            raise ArgumentError.new('User: mnemonicCode must be a string')
        end
        @mnemonicCode = mnemonicCode.dup()
    end

    
    def apiKey=(apiKey)
        if !apiKey.is_a?(String)
            raise ArgumentError.new('User: apiKey must be a string')
        end
        @apiKey = apiKey.dup()
    end


    def personId=(personId)
        if !personId.is_a?(String)
            raise ArgumentError.new('User: personId must be a string')
        end
        @personId = personId.dup()
    end


    def authPublicKey=(authPublicKey)
        if !authPublicKey.is_a?(String)
            raise ArgumentError.new('User: authPublicKey must be a string')
        end
        @authPublicKey = authPublicKey.dup()
    end


    def publicKey=(publicKey)
        if !publicKey.is_a?(String)
            raise ArgumentError.new('User: publicKey must be a string')
        end
        @publicKey = publicKey.dup()
    end


    def notificationsToken=(notificationsToken)
        if !notificationsToken.is_a?(String)
            raise ArgumentError.new('User: notificationsToken must be a string')
        end
        @notificationsToken = notificationsToken.dup()
    end


    def entityEmail=(entityEmail)
        if !ValueCheck.checkEmailAddress(entityEmail)
            raise ArgumentError.new('User: entityEmail must be a string email address')
        end
        @entityEmail = entityEmail.dup()
    end


    def emails=(emails)
        if !emails.is_a?(Array)
            raise ArgumentError.new('User: emails must be an array of Email objects')
        end
        emails.each do | email |
            if !email.is_a?(Email)
                raise ArgumentError.new('User: emails must be an array of Email objects')
            end
        end
        @emails = emails.dup()
    end


    def fromHash(attributeHash)
        if !attributeHash.nil?
            @id                 = attributeHash['id']
            @primaryEmail       = attributeHash['primaryEmail']
            @username           = attributeHash['username']
            @password           = attributeHash['password']
            @passwordTemporary  = attributeHash['passwordTemporary']
            @passPhrase         = attributeHash['passPhrase']
            @mnemonicCode       = attributeHash['mnemonicCode']
            @apiKey             = attributeHash['apiKey']
            @personId           = attributeHash['personId']
            @authPublicKey      = attributeHash['authPublicKey']
            @publicKey          = attributeHash['publicKey']
            @notificationsToken = attributeHash['notificationsToken']
            @entityEmail        = attributeHash['entityEmail']

            if !attributeHash['emails'].nil?
                @emails = []

                attributeHash['emails'].each do | emailHash | 
                    @emails.push(Email.new().fromHash(emailHash));
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

                if key.eql?('emails')
                    hash[key] = []
                    @emails.each do | email |
                        hash[key].push(email.toHash())
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
