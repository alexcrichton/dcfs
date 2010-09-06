require 'fargo/publisher'

module DCFS
  module Proxy
    class FargoClient < Client

      include Fargo::Publisher

      def subscribe *args, &block
        super
        open_subscription unless subscribed_to_server?
      end

      def unsubscribe *args, &block
        super
        close_subscription if subscribed_to_server?
      end

      def subscribed_to_server?
        !@subscription_socket.nil?
      end

      def open_subscription
        @subscription_socket = open_socket
        # This indicates that this connection will be a subscribing client
        @subscription_socket << encode('new_client_subscription')

        # read stuff and publish it as necessary
        @subscription_thread = Thread.start { loop { read_subscription } }
      end

      def read_subscription
        return close_subscription if @subscription_socket.closed?

        # Get the data and decode it. Then publish it.
        data = @subscription_socket.gets DELIM
        publish *decode(data)
      end

      def close_subscription
        @subscription_thread.exit  unless @subscription_thread.nil?
        @subscription_socket.close unless @subscription_socket.nil?
        @subscription_socket = @subscription_thread = nil
      end

    end
  end
end
