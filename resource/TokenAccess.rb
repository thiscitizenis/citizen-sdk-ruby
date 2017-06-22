class TokenAccess

    attr_reader :access

    def initialize()
        @access = 0   # Integer (AccessType)
    end


    def access=(access)
        if !access.is_a?(Fixnum)
            raise ArgumentError.new('TokenAccess: access must be an integer')
        end
        if !TokenAccess.verify(access)
            raise ArgumentError.new('TokenAccess: invalid access type')
        end

        @access = access
    end


    def TokenAccess.verify(access)
        valid = true
        accessCheck = access

        if accessCheck < 0
            valid = false
        end

        AccessType.constants.each do | accessTypeSymbol |
            if accessCheck & AccessType.const_get(accessTypeSymbol) > 0
                accessCheck -= AccessType.const_get(accessTypeSymbol)
            end
        end

        if accessCheck != 0
            valid = false
        end

        return valid
    end


    def TokenAccess.contains(access, accessType)
        if accessType & access > 0
            return true
        end

        return false
    end


    def contains(accessType)
        if accessType & @access > 0
            return true
        end

        return false
    end


    def add(accessType)
        if accessType & @access == 0
            @access += accessType
        end

        return @access
    end


    def remove(accessType)
        if accessType & @access > 0
            @access -= accessType
        end

        return @access
    end


    def all()
        accessAll = 0
        AccessType.constants.each do | accessTypeSymbol |
            accessAll += AccessType.const_get(accessTypeSymbol)
        end

        return accessAll
    end


    def none()
        return 0
    end


    def fromHash(accessTypeHash)
        @access = 0

        if !accessTypeHash.nil?
            AccessType.constants.each do | accessTypeSymbol |
                accessType = AccessType.const_get(accessTypeSymbol)
                if !accessTypeHash[accessType].nil? && accessTypeHash[accessType]
                    @access += AccessType.const_get(accessType)
                end
            end
        end

        return self
    end


    def toHash()
        hash = {}

        AccessType.constants.each do | accessTypeSymbol |
            if @access & AccessType.const_get(accessTypeSymbol) > 0
                hash[accessTypeSymbol.to_str] = true
            else 
                hash[accessTypeSymbol.to_str] = false
            end
        end

        return hash
    end


    def to_s()
        return self.toHash().to_s()
    end
end
