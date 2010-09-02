module DtellaFS
  class StatVfs

    attr_accessor :f_bsize, :f_frsize, :f_blocks, :f_bfree, :f_bavail, :f_files,
      :f_ffree, :f_favail, :f_fsid, :f_flag, :f_namemax

    def initialize
      @f_bsize    = 0
      @f_frsize   = 0
      @f_blocks   = 0
      @f_bfree    = 0
      @f_bavail   = 0
      @f_files    = 0
      @f_ffree    = 0
      @f_favail   = 0
      @f_fsid     = 0
      @f_flag     = 0
      @f_namemax  = 0
    end

  end
end