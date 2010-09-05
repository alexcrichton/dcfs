require 'active_support/core_ext/object/try'

module DCFS
  class NickDirectory

    def initialize nick, client
      @nick, @client = nick, client

      # @client.subscribe do |type, message|
      #   if type == :file_list && message[:nick] == @nick
      #     @file_list = @client.file_list(@nick)
      #   end
      # end
      # load_file_list
    end

    def contents path
      load_file_list if @file_list.nil?
      drilldown(path).try :keys
    end

    def size(path)
      400
      # if path == '/'
      #   442246
      # else
      #   read_file(path).size
      # end
    end
    
    def directory? path
      load_file_list if @file_list.nil?
      drilldown(path).is_a? Hash
    end

    def file? path
      load_file_list if @file_list.nil?
      drilldown(path).is_a? Struct
    end

    def read_file(path)
      "Hello, World!\n"
    end
    
    protected
    
    def drilldown path
      path.split('/').inject(@file_list) { |hash, part| 
        hash ? hash[part] : nil
      }
    end
    
    def load_file_list
      @file_list = @client.file_list!(@nick) || {}
    end
  end
end