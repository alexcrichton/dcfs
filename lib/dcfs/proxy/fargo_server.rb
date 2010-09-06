module DCFS
  module Proxy

    # This is an extension of the radio proxy server which supports
    # subscriptions to the underlying object.
    class FargoServer < Server

      def initialize *args
        super

        @client        = @for
        @subscriptions = []

        # Subscribe to the client and publish everything over the server to
        # clients who are subscribed.
        @client.subscribe { |type, hash|
          data = encode [type, hash]

          # Publish this data over all subscriptions
          @subscriptions.each{ |socket|
            if socket.closed?
              @subscriptions.delete socket
            else
              begin
                socket << data
              rescue => e
                socket.close rescue nil
                @subscriptions.delete socket
              end
            end
          }
        }
      end

      def new_subscription? obj
        obj == 'new_client_subscription'
      end

      # Override this method to correctly handle new subscription sockets
      def answer socket, args
        if new_subscription? args.first
          @subscriptions << socket
        else
          super
        end
      end

    end
  end
end
