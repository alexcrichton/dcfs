module DCFS
  module Proxy
    class Client

      include Utils

      attr_accessor :port, :path

      def initialize port_or_path
        resolve_port_or_path port_or_path
      end

      def proxy_data *things
        socket = open_socket

        socket << encode(things)
        obj = decode socket.gets(DELIM)
        socket.close

        # handle exceptions appropriately
        raise obj if obj.is_a?(Exception)

        obj
      end

      def method_missing name, *args
        proxy_data name, *args
      end

      def open_socket
        if @port
          TCPSocket.open '127.0.0.1', @port
        else
          UNIXSocket.open @path
        end
      end

    end
  end
end
