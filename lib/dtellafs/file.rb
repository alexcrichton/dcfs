module DtellaFS
  class File

    attr_accessor :name, :mode, :actime, :modtime, :uid, :gid, :content

    def initialize name, mode, uid, gid
      @actime  = 0
      @modtime = 0
      @xattr   = {}
      @content = ''
      @uid     = uid
      @gid     = gid
      @name    = name
      @mode    = mode
    end

    def listxattr #hey this is a raw interface you have to care about the \0
      list = ""
      @xattr.each {|key,value| list = list + key + "\0" }
      list
    end

    def setxattr name, value, flag
      @xattr[name] = value #TODO:don't ignore flag
    end

    def getxattr name
      @xattr[name]
    end

    def removexattr name
      @xattr.delete name
    end

    def size
      content.size
    end 

    def dir_mode
      (@mode & 170000) >> 12
    end

    def isdir
      false
    end

    def follow path_array
      if path_array.length != 0 then
        raise Errno::ENOTDIR.new
      else
        self
      end
    end

    def to_s
      "File: " + @name + "(" + @mode.to_s + ")"
    end
  end
end
