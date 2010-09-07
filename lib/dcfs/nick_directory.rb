require 'active_support/core_ext/object/try'

module DCFS
  class NickDirectory

    attr_accessor :file_list

    def initialize nick, client
      @nick, @client = nick, client
    end

    def contents path
      load_file_list if @file_list.nil?
      drilldown(path).try :keys
    end

    def size path
      entity = drilldown path
      entity.is_a?(Struct) ? entity.size : 4096
    end

    def directory? path
      load_file_list if @file_list.nil?
      drilldown(path).is_a? Hash
    end

    def file? path
      load_file_list if @file_list.nil?
      drilldown(path).is_a? Struct
    end

    def raw_open path, mode
      mode == 'r'
    end

    def raw_read path, off, size
      struct = drilldown(path)

      thread = Thread.current
      data   = nil

      block = lambda { |type, message|
        val = false

        if message[:nick] == @nick
          case type
            when :download_finished, :download_failed, :download_disconnected
              if File.exists? message[:file]
                data = File.read message[:file]
                File.delete message[:file]
              end
              val = true
          end
        end

        val
      }

      @client.timeout_response(10, block) do
        @client.download @nick, struct.file, struct.tth, size, off
      end

      data
    end

    protected

    def drilldown path
      path.split('/').inject(@file_list) { |hash, part|
        hash ? hash[part] : nil
      }
    end

    def load_file_list
      # Schedule the file list to be gotten. Don't wait for it here. It'll show
      # up once downloaded via the subscribe in the root directory
      @client.file_list(@nick)

      @file_list = {}
    end
  end
end
