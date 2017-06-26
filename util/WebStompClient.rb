# Simple STOMP over web socket client geared towards sending a
# a single message and receiving a corresponding reply.


class WebStompClient

    module WebStompState
        UNINITIALISED        = 0
        WEB_SOCKET_CONNECTED = 1
        STOMP_CONNECTED      = 2
        MESSAGE_WAIT         = 3
        MESSAGE_RECEIVED     = 4
        FINISHED             = 5
        ERROR                = -1
    end


    def initialize()
        @state                = 0     # StompState
        @webSocket            = nil   # Faye::WebSocket::Client
        @stompSubscriptionId  = 101   # Integer
        @defaultTimeout       = 60    # Integer
    end


    def state
        return @state
    end


    def connectWebSocket(endpoint)
        if Config::API_SECURE
            url = 'wss://'
        else
            url = 'ws://'
        end

        url += "#{Config::API_HOST}:#{Config::API_PORT}/#{endpoint}"

        @webSocket = Faye::WebSocket::Client.new(url)
    end


    def closeWebSocket()
        if !@webSocket.nil?
            @webSocket.close
        end
    end


    def stompConnect()
        operation = "CONNECT"

        headers   = {
                        'accept-version:' => '1.0,1.1'
                    }

        sendStompOperation(operation: operation, headers: headers)
    end


    def stompSend(destination, data, contentType)
        operation = "SEND"

        headers   = {
                        'content-type' => contentType,
                        'destination' => destination
                    }

        sendStompOperation(operation: operation, headers: headers, data: data)
    end


    def stompSubscribe(destination)
        operation = "SUBSCRIBE"

        headers   = {
                        'id' => @stompSubscriptionId,
                        'destination' => destination
                    }

        sendStompOperation(operation: operation, headers: headers)
    end


    def stompUnsubscribe()
        operation = "UNSUBSCRIBE"

        headers   = {
                        'id' => @stompSubscriptionId
                    }

        sendStompOperation(operation: operation, headers: headers)
    end


    def stompDisconnect()
        operation = "DISCONNECT"

        sendStompOperation(operation: operation)
    end


    def sendStompOperation(operation:, headers: nil, data: nil)
        message = "#{operation}\r\n"

        if !headers.nil?
            headers.each do | key, value |
                message += "#{key}:#{value}\r\n"
            end
        end

        message += "\r\n"

        if !data.nil?
            message += "#{data}"
        end

        if Config::DEBUG
            puts("WebStompClient: send:\n#{message}")
        end
         
        message += "\x00"

        @webSocket.send(message)
    end


    def parseStompReceivedData(data)
        if /\n\n/ =~ data
            return data.split(/\n\n/)[1].gsub!(/[^0-9A-Za-z\{\}\"\'\:\,\.\-\=\/\+]/, '')
        end

        return nil
    end


    def handleStompMessage(message)
 
        if Config::DEBUG
            puts("WebStompClient: recv:\n#{message}")
        end

        if /^CONNECTED/i =~ message
            @state = WebStompState::STOMP_CONNECTED
            return

        elsif /^MESSAGE/i =~ message
            @state = WebStompState::MESSAGE_RECEIVED
            return

        else
            @state = WebStompState::ERROR
            return
        end
    end


    def sendStompMessageAndReceiveResponse(webSocketEndpoint:,
                                           stompSendLocation:,
                                           stompReceiveLocation:,
                                           message:,
                                           contentType:,
                                           timeout: @defaultTimeout)

        if !ValueCheck.checkUri(webSocketEndpoint)
            raise ArgumentError.new('WebStompClient: webSocketEndpoint must be a URI string')
        end
        if !ValueCheck.checkUri(stompSendLocation)
            raise ArgumentError.new('WebStompClient: stompSendLocation must be a URI string')
        end
        if !ValueCheck.checkUri(stompReceiveLocation)
            raise ArgumentError.new('WebStompClient: stompReceiveLocation must be a URI string')
        end
        if !message.is_a?(String)
            raise ArgumentError.new('WebStompClient: message must be a string')
        end
        if !contentType.is_a?(String)
            raise ArgumentError.new('WebStompClient: contentType must be a string')
        end
        if !timeout.is_a?(Fixnum)
            raise ArgumentError.new('WebStompClient: timeout must be an integer')
        end

        receivedMessage = nil

        EM.run do
            EM.add_timer(@defaultTimeout) do
                @state = WebStompState::ERROR
                puts("WebStompClient: timeout")
                EM.stop()
            end

            connectWebSocket(webSocketEndpoint)

            @webSocket.on :open do | event |
                if Config::DEBUG
                    puts("WebStompClient: socket open")
                end

                @state = WebStompState::WEB_SOCKET_CONNECTED

                stompConnect()
            end

            @webSocket.on :message do | event |

                handleStompMessage(event.data)

                if state == WebStompState::ERROR
                    closeWebSocket()
                    EM.stop()

                elsif state == WebStompState::STOMP_CONNECTED
                    stompSend(stompSendLocation, message, contentType)
                    stompSubscribe(stompReceiveLocation)
                    @state = WebStompState::MESSAGE_WAIT

                elsif state == WebStompState::MESSAGE_RECEIVED
                    receivedMessage = parseStompReceivedData(event.data)
                    stompUnsubscribe()
                    stompDisconnect()
                    closeWebSocket()
                    @state = WebStompState::FINISHED
                end
            end

            @webSocket.on :close do | event |
                if Config::DEBUG
                    puts("WebStompClient: socket close")
                end

                if state == WebStompState::MESSAGE_RECEIVED
                    @state = WebStompState::FINISHED

                elsif state != WebStompState::FINISHED
                    @state = WebStompState::ERROR
                end

                @webSocket = nil
                EM.stop()
            end

            @webSocket.on :error do | event |
                if Config::DEBUG
                    puts("WebStompClient: socket error")
                end

                closeWebSocket()
                @state = WebStompState::ERROR
                EM.stop()
            end
        end

        if @state == WebStompState::ERROR
            raise RuntimeError.new('WebStompClient: error getting web token auth details')
        end

        return receivedMessage
    end
end
