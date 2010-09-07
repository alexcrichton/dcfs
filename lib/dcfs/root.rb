require 'fargo'
require 'drb'

Thread.abort_on_exception = true

module DCFS
  class Root < FuseFS::MetaDir

    def initialize
      @nicks = {}
      super
    end

    def contents path
      subscribe if @client.nil?

      super
    end

    def spawn_client_process
      @client_pid = fork {
        @real_client = Fargo::Client.new

        DRb.start_service 'drbunix:///tmp/dcfs.sock', @real_client
        @real_client.connect
        DRb.thread.join
      }
    end

    def client
      @client ||= begin
        DRb.stop_service
        DRb.start_service 'drbunix:///tmp/dcfs2.sock'
        DRbObject.new nil, 'drbunix:///tmp/dcfs.sock'
      end
    end

    protected

    def subscribe
      client.nicks.each{ |n| register_nick n }

      client.subscribe do |type, map|
        case type
          when :hello
            unless directory? map[:who]
              register_nick map[:who]
            end
          when :nick_list
            map[:nicks].each{ |n| register_nick n }
          when :quit
            unregister_nick map[:who]
          when :hub_disconnected
            # Clear out all directories?
          when :file_list
            @nicks[map[:nick]].file_list = client.file_list map[:nick]
        end
      end
    end

    def register_nick nick
      mkdir '/' + nick, @nicks[nick] = DCFS::NickDirectory.new(nick, @client)
    end

    def unregister_nick nick
      @nicks.delete nick
      rmdir nick
    end

  end
end
