class TokenWrapper

    attr_reader :tokens, 


    def initialize()
        @tokens = nil   # Array of Token objects
    end


    def tokens=(tokens)
        if !tokens.is_a?(Array)
            raise ArgumentError.new('TokenWrapper: tokens must be an array of Tokens')
        end
        tokens.each do | token |
            if !token.is_a?(Token)
                raise ArgumentError.new('TokenWrapper: tokens must be an array of Tokens')
            end
        end
        @tokens = tokens.dup()
    end
        

    def fromHash(attributeHash)
        if !attributeHash.nil? && !attributeHash['tokens'].nil?
            @tokens = []

            attributeHash['tokens'].each do | tokenHash |
                @tokens.push(Token.new().fromHash(tokenHash));
            end
        end

        return self
    end


    def toHash()
        hash = {}

        if !@tokens.nil?
            list = []
            @tokens.each do | token |
                list.push(token)
            end
            hash[:'tokens'] = list
        end
    end


    def to_s()
        return self.toHash().to_s()
    end


    def length()
        if !@tokens.nil?
            return @tokens.length
        end

        return 0
    end


    def push(token)
        if !@tokens.nil?
            @tokens.push(token)
        else
            @tokens = [ token ]
        end
    end


    def get(index)
        if !@tokens.nil? && index >= 0 && index < tokens.length
            return @tokens[index]
        end

        return nil
    end
end
