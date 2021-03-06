require 'active_support/core_ext/numeric'
require 'active_support/core_ext/time/acts_like'
require 'active_support/core_ext/time/calculations'
require 'active_support/core_ext/module/synchronization'

module DCFS
  class DCFile

    @@read_lock = Mutex.new

    def initialize client, download, channel
      @client, @download, @channel = client, download, channel

      @start, @end = -1, -1
      @read_count = 0
    end

    def read size, offset
      size = @download.size - offset if size + offset > @download.size

      if size < @start || @end < size + offset || @cache_file.nil?
        if @downloading
          Fargo.logger.debug 'Already downloading, why are you reading again!?'
          raise 'Already downloading, why are you reading again!?'
        elsif @fargo_downloading
          Fargo.logger.debug 'Requested a read while fargo was downloading'

          # We're downloading from fargo, so wait for the downloaded amount to
          # exceed what we're asking for. If more is asked for, we'll do that
          # afterwards
          timeout_download(size, offset)

          Fargo.logger.debug 'Downloaded enough, now currently recursing'

          # A lot of edge cases can happen here, recurse and let this handle it
          # again
          return self.read_without_synchronization size, offset
        else
          download_remotely size, offset
        end
      end

      data = nil
      if @cache_file
        File.open(@cache_file){ |f|
          f.seek offset
          data = f.read size
        }
      end

      @last_read = Time.now

      data
    end

    synchronize :read, :with => :@@read_lock

    def download_remotely size, offset
      if @start == -1 || @end == -1 || offset < @start || offset - @end > 10 * size
        dlstart = offset
        dlend   = offset + [size, block_size].max

        @start = @end = dlstart
      else
        dlstart = @end
        dlend   = @end + [offset + size - @end + 1, block_size].max
      end

      dlend = [dlend, @download.size].min

      Fargo.logger.debug "Requested #{size} bytes offset by #{offset}"
      Fargo.logger.debug "Starting download at #{dlstart}, ending #{dlend}"
      Fargo.logger.debug "(#{dlend - dlstart})"

      @downloading = true
      @fargo_downloading = true

      Fargo.logger.debug "Downloading #{@download.inspect}"

      timeout_download(size, offset) do
        schedule_download dlend - dlstart, dlstart
      end

      @downloading = false
    end

    def remove_cache
      File.delete @cache_file if @cache_file && File.exists?(@cache_file)
    end

    def block_size
      @read_count = 0 if @last_read.nil? || @last_read > 20.seconds.ago

      10.megabytes * (2**@read_count)
    end

    protected

    def timeout_download size, offset
      # 500K/s should be a reasonable speed to assume. Slower than that is just
      # silly anyway.
      timeout = [size / 500.kilobytes, 10].max

      current = Thread.current
      sid = @channel.subscribe do |type, message|
        current.wakeup if size + offset <= @end || !@fargo_downloading
      end

      yield if block_given?
      sleep timeout
      @channel.unsubscribe sid
    end

    def schedule_download size, offset
      @read_count += 1

      sid = @channel.subscribe do |type, message|
        if message[:nick] == @download.nick
          case type
            when :download_progress
              @end = @start + message[:size]
              @cache_file = message[:file]
            when :download_finished, :download_failed, :download_disconnected
              @fargo_downloading = false
              @channel.unsubscribe sid
          end
        end
      end

      @client.download @download.nick, @download.name, @download.tth,
          size, offset
    end

  end
end
