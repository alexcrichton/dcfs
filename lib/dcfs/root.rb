require 'fargo'

module DCFS
  class Root
    def initialize
      @client = Fargo::Client.new
    end

    def contents path
      @client.nicks
    end

    def size path
      read_file(path).size
    end

    def file? path
      @client.nicks.include? path.gsub(/^\//, '')
    end

    def read_file(path)
      path
    end
  end
end
