class RestClientWrapper

    def RestClientWrapper.sendRequest(method:,
                                      endpoint:,
                                      content: nil,
                                      apiKey: nil,
                                      mnemonic: nil,
                                      sessionNonce: nil,
                                      sessionKey: nil,
                                      loginSignature: nil,
                                      contentType: 'application/json')

       if !ValueCheck.checkHttpOperation(method)
           raise ArgumentError.new('RestClientWrapper: method must be a http method string')
       end
       if !ValueCheck.checkUri(endpoint)
           raise ArgumentError.new('RestClientWrapper: endpoint must be a valid URI')
       end
       if !apiKey.nil? && !apiKey.is_a?(String)
           raise ArgumentError.new('RestClientWrapper: apiKey must be a string')
       end
       if !mnemonic.nil? && !mnemonic.is_a?(String)
           raise ArgumentError.new('RestClientWrapper: mnemonic must be a string')
       end
       if !sessionNonce.nil? && !sessionNonce.is_a?(String)
           raise ArgumentError.new('RestClientWrapper: sessionNonce must be a string')
       end
       if !sessionKey.nil? && !sessionKey.is_a?(String)
           raise ArgumentError.new('RestClientWrapper: sessionKey must be a string')
       end
       if !contentType.is_a?(String)
           raise ArgumentError.new('RestClientWrapper: contentType must be a string')
       end

       if method.eql?('post') || method.eql?('put')
           headers = { 'Content-Type' => contentType }
       else 
           headers = {}
       end
 
       if !apiKey.nil?
           headers[:'AuthorizationCitizen'] = apiKey
       end

       if !mnemonic.nil?
           headers[:'X-code'] = mnemonic
       end

       if !loginSignature.nil?
           headers[:'X-signature'] = loginSignature
       end

       if !sessionNonce.nil? && !sessionKey.nil?
           headers[:'Session-nonce'] = sessionNonce
           headers[:'Session-key'] = sessionKey
       end

       if !content.nil?
           if (contentType.eql? 'application/json') && (content.is_a? String)
               payload = "\"#{content}\""   # Text node.
           elsif (contentType.eql?'application/json') && (content.is_a? Hash)
               payload = content.to_json()
           elsif (contentType.eql?'application/json')
               payload = content.toHash().to_json()
           else 
               payload = content
           end
       end

       if Config::API_SECURE
           authority = "https://"
       else
           authority = "http://"
       end

       authority += Config::API_HOST + ":" + Config::API_PORT.to_s

       if Config::DEBUG
           puts("RestClientWrapper: sending: #{method} #{authority}/#{endpoint}")
       end

       if !content.nil?
           response = RestClient::Request.execute(
                          method: method,
                          url: "#{authority}/#{endpoint}",
                          headers: headers,
                          payload: payload
                      )
       else
           response = RestClient::Request.execute(
                          method: method,
                          url: "#{authority}/#{endpoint}",
                          headers: headers
                      )
       end

       if Config::DEBUG
           puts("RestClientWrapper: response code: #{response.code}")
       end

       return response
    end
end
