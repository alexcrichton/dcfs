require 'fargo'
require 'drb'

Thread.abort_on_exception = true

module DCFS
  class Root < FuseFS::MetaDir

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
      DRb.start_service
    end

    def client
      @client ||= DRbObject.new nil, 'drbunix:///tmp/dcfs.sock'
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
            # @nicks << map[:who] unless @nicks.include? map[:who]
          # when :myinfo
          #   @nick_info[map[:nick]] = map
          when :nick_list
            map[:nicks].each{ |n| register_nick n }
            # @nicks = map[:nicks]
          when :quit
            unregister_nick map[:who]
            # @nicks.delete map[:who]
            # @nick_info.delete map[:who]
          when :hub_disconnected
            # @nicks.clear

            # @nick_info.clear
          # when :userip
            # map[:users].each_pair{ |nick, ip| @nick_info[nick][:ip] = ip }
        end
      end
    end

    def register_nick nick
      mkdir '/' + nick, DCFS::NickDirectory.new(nick, @client)
    end

    def unregister_nick nick
      rmdir nick
    end

  end
end
