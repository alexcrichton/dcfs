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

    def read_file path
      "Hello, World!\n"
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
