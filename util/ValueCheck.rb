class ValueCheck

    def ValueCheck.checkStringConstant(arg, constants)

        if !arg.is_a?(String)
            return false
        end

        if !constants.is_a?(Module)
            return false
        end

        match = false
        constants.constants.each do | constantSymbol |
            if arg.eql?(constants.const_get(constantSymbol))
                match = true
            end
        end

        return match
    end


    def ValueCheck.checkSymbolAsString(arg, constants)

        if !arg.is_a?(String)
            return false
        end

        if !constants.is_a?(Module)
            return false
        end

        match = false
        constants.constants.each do | constantSymbol |
            if arg.eql?(constantSymbol.to_s())
                match = true
            end
        end

        return match
    end


    def ValueCheck.getConstantsAsCommaSeperatedString(constants)

        if !constants.is_a?(Module)
            return false
        end

        commaSeperatedString = ""
        constants.constants.each do | constantSymbol |
            const = constants.const_get(constantSymbol)
            commaSeperatedString += const + ", "
        end

        commaSeperatedString = commaSeperatedString.gsub(/\,\s*/, '')

        return commaSeperatedString
    end


    def ValueCheck.checkEmailAddress(emailAddress)

        if !emailAddress.is_a?(String)
            return false
        end

        if !(/^[a-zA-Z0-9\+\-\_\.]+\@{1}([a-zA-Z0-9\-]+\.)+[a-zA-Z0-9\-]+$/ =~ emailAddress)
            return false
        end

        if /\.\./ =~ emailAddress
            return false
        end

        return true
    end


    def ValueCheck.checkUri(uri)

        if !uri.is_a?(String)
            return false
        end

        if uri.length < 1
            return false
        end

        if /[^a-zA-Z0-9\+\-\.\_\/]/ =~ uri
            return false
        end

        return true
    end


    def ValueCheck.checkHttpOperation(op)
        validOps = [
                       'GET',
                       'POST',
                       'PUT',
                       'DELETE'
                   ]

        validOps.each do | validOp |
            if op.casecmp(validOp) == 0
                return true
            end
        end

        return false
    end
end
