class PersonActions

    def PersonActions.getPerson(personId:,
                                apiKey:,
                                mnemonic: nil,
                                sessionNonce: nil,
                                sessionKey: nil)

        if !(!mnemonic.nil? || (!sessionNonce.nil? && !sessionKey.nil?))
            raise ArgumentError.new('PersonActions.getPerson: either mnemonic or both sessionNonce and sessionKey must be given')
        end

        response = RestClientWrapper::sendRequest(method: 'get',
                                                  endpoint: "persons/#{personId}",
                                                  apiKey: apiKey,
                                                  mnemonic: mnemonic,
                                                  sessionNonce: sessionNonce,
                                                  sessionKey: sessionKey)

        if response.code != 200
            raise RuntimeError.new("PersonActions.getPerson: error running request: response code: #{response.code}")
        end

        return Person.new.fromHash(JSON.parse(response.body))
    end


    def PersonActions.setName(personId:,
                              name:,
                              apiKey:)

        response = RestClientWrapper::sendRequest(method: 'post',
                                                  endpoint: "persons/#{personId}/name",
                                                  content: name,
                                                  apiKey: apiKey)

        if response.code != 200
            raise RuntimeError.new("PersonActions.setName: error running request: response code: #{response.code}")
        end

        return Person.new.fromHash(JSON.parse(response.body))
    end


    def PersonActions.setAddress(personId:,
                                 address:,
                                 apiKey:)

        response = RestClientWrapper::sendRequest(method: 'post',
                                                  endpoint: "persons/#{personId}/address",
                                                  content: address,
                                                  apiKey: apiKey)

        if response.code != 200
            raise RuntimeError.new("PersonActions.setAddress: error running request: response code: #{response.code}")
        end

        return Address.new.fromHash(JSON.parse(response.body))
    end


    def PersonActions.setPhone(phone:,
                               apiKey:)

        if phone.personId.nil?
            raise ArgumentError.new('PersonActions.setPhone: phone object not initialised with person ID')
        end

        response = RestClientWrapper::sendRequest(method: 'post',
                                                  endpoint: "persons/#{phone.personId}/phones",
                                                  content: phone,
                                                  apiKey: apiKey)

        if response.code != 200
            raise RuntimeError.new("PersonActions.setPhone: error running request: response code: #{response.code}")
        end

        return Phone.new.fromHash(JSON.parse(response.body))
    end


    def PersonActions.getPhone(personId:,
                               apiKey:,
                               mnemonic: nil,
                               sessionNonce: nil,
                               sessionKey: nil)

        if !(!mnemonic.nil? || (!sessionNonce.nil? && !sessionKey.nil?))
            raise ArgumentError.new('PersonActions.getPerson: either mnemonic or both sessionNonce and sessionKey must be given')
        end

        response = RestClientWrapper::sendRequest(method: 'get',
                                                  endpoint: "persons/#{personId}/phone",
                                                  apiKey: apiKey,
                                                  mnemonic: mnemonic,
                                                  sessionNonce: sessionNonce,
                                                  sessionKey: sessionKey)

        if response.code != 200
            raise RuntimeError.new("PersonActions.setPhone: error running request: response code: #{response.code}")
        end

        return Phone.new.fromHash(JSON.parse(response.body))
    end


    def PersonActions.confirmPhone(phone:,
                                   apiKey:)

        response = RestClientWrapper::sendRequest(method: 'post',
                                                  endpoint: "phones/#{phone.id}/confirm",
                                                  content: phone,
                                                  apiKey: apiKey)

        if response.code != 200
            raise RuntimeError.new("PersonActions.setPhone: error running request: response code: #{response.code}")
        end

        return true
    end


    def PersonActions.setOrigin(person:,
                                apiKey:)

        if person.id.nil?
            raise ArgumentError.new('PersonActions.setOrigin: person object not initialised with person ID')
        end

        response = RestClientWrapper::sendRequest(method: 'put',
                                                  endpoint: "persons/#{person.id}/origin",
                                                  content: person,
                                                  apiKey: apiKey)

        if response.code != 200
            raise RuntimeError.new("PersonActions.setOrigin: error running request: response code: #{response.code}")
        end

        return Person.new.fromHash(JSON.parse(response.body))
    end


end
