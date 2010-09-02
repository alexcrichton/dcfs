module DtellaFS
  class Stat

    attr_accessor :uid, :gid, :mode, :size, :atime, :mtime, :ctime, :dev, :ino,
      :nlink, :rdev, :blksize, :blocks

    def initialize
      @uid     = 0
      @gid     = 0
      @mode    = 0
      @size    = 0
      @atime   = 0
      @mtime   = 0
      @ctime   = 0
      @dev     = 0
      @ino     = 0
      @nlink   = 0
      @rdev    = 0
      @blksize = 0
      @blocks  = 0
    end

  end
end