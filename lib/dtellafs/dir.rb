module DtellaFS
  class Dir < Hash

    attr_accessor :name, :mode , :actime, :modtime, :uid, :gid

    def initialize name, mode
      @uid     = 0
      @gid     = 0
      @actime  = 0     #of couse you should use now() here!
      @modtime = 0     # -''-
      @xattr   = {}
      @name    = name
      @mode    = mode | (4 << 12) #yes! we have to do this by hand
    end

    def listxattr
      @xattr.each {|key,value| list=list+key+"\0"}
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

    def dir_mode
      (@mode & 170000) >> 12 #see dirent.h
    end

    def size
      48 #for testing only
    end

    def isdir
      true
    end

    def insert_obj(obj,path)
      d = self.search File.dirname(path)
      if d.isdir then
        d[obj.name] = obj
      else
        raise Errno::ENOTDIR.new(d.name)
      end
      d
    end

    def remove_obj path
      d = self.search File.dirname(path)
      d.delete File.basename(path)
    end

    def search path
      p = path.split('/').delete_if{ |x| x == '' }
      if p.length == 0 then
        self
      else
        self.follow p
      end
    end

    def follow path_array
      if path_array.length == 0 then
        self
      else
        d = self[path_array.shift]
        if d
          d.follow path_array
        else
          raise Errno::ENOENT.new
        end
      end
    end

    def to_s
      "Dir: " + @name + "(#{@mode.to_s})"
    end
  end
end
