class Random

    def Random.getRandomString(len)
        chars = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
        return (0...len).map { chars[rand(chars.length)] }.join
    end
end
