module DCFS
  module Proxy
    class Server

      include Utils

      def initialize object, port_or_path
        @for = object
        resolve_port_or_path port_or_path
        @looping = true
      end

      def connect
        if @path
          @server = UNIXServer.new @path
          at_exit { File.delete @path if @path && File.exists?(@path) }
        else
          @server = TCPServer.new @port
        end

        while @looping do
          socket = @server.accept
          next if socket.nil?

          spawn_thread {
            data = socket.gets DELIM

            # answer the request
            answer socket, decode(data) unless data.nil?

            thread_complete
          }
        end
      end

      def disconnect
        @looping = false
        @server.close unless @server.nil?
        @server = nil
        File.delete @path if @path

        join_all_threads
      end

      # This is here so subclasses may overwrite this
      def answer socket, data
        proxy socket, data
      end

      private

      def proxy socket, args
        # Send the method to the client, returning the result.
        # The socket is then closed.
        begin
          value = @for.send *args
          socket << encode(value)
        rescue => e
          socket << encode(e) unless socket.closed?
        end

        socket.close
      end

    end
  end
end
