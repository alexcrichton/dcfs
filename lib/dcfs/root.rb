require 'fargo'
require 'drb'
require 'active_support/core_ext/object/try'

module DCFS
  class Root

    def initialize
      @file_lists   = {}
      @opened_files = {}
    end

    def contents path
      if path == '/'
        client.nicks || []
      else
        nick, path = split_path path

        drilldown(path || '', file_list(nick)).keys
      end
    end

    def directory? path
      nick, path = split_path path
      if path == ''
        client.nicks.include? nick
      else
        drilldown(path, file_list(nick)).is_a?(Hash)
      end
    end

    def file? path
      nick, path = split_path path
      if path == ''
        false
      else
        drilldown(path, file_list(nick)).is_a?(Struct)
      end
    end

    def size path
      nick, path = split_path path
      entity = drilldown path, file_list(nick)
      entity.is_a?(Struct) ? entity.size : 4096
    end

    def client
      @client ||= begin
        DRb.start_service
        DRbObject.new nil, 'druby://localhost:9090'
      end
    end

    def raw_open path, mode
      puts "raw opening #{path.inspect}"
      nick, subpath = split_path path

      if mode == 'r'
        @opened_files[path] = DCFile.new(nick, subpath, client,
          drilldown(subpath, file_list(nick)))
        true
      else
        false
      end
    end

    def raw_read path, off, size
      puts "raw reading #{path.inspect} with off #{off.inspect}:#{size.inspect}"
      nick, subpath = split_path path

      puts "Reading from: #{@opened_files[path].inspect}"
      @opened_files[path].read size, off
    rescue => e
      puts "Error reading!: #{e}"
      puts e.backtrace.join("\n")
      nil
    end

    def raw_close path
      puts "raw closing #{path.inspect}"
      @opened_files.delete(path).try(:remove_cache)
    rescue => e
      puts "Error closing!: #{e}"
      puts e.backtrace.join("\n")
      nil
    end

    protected

    def drilldown path, list
      path.split('/').inject(list) { |hash, part|
        hash ? hash[part] : nil
      }
    end

    def split_path path
      nick, path = path.split('/', 3)[1..-1]
      [nick, path || '']
    end

    def file_list nick
      if @file_lists[nick] && @file_lists[nick].size > 0
        return @file_lists[nick]
      end

      list = client.file_list nick
      list = {} unless list.is_a?(Hash)
      @file_lists[nick] = list
    end

  end
end
