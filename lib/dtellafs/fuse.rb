module DtellaFS
  class Fuse < RFuse::Fuse

    def initialize(mnt,kernelopt,libopt,root)
      super(mnt,kernelopt,libopt)
      @root=root
    end

    # The old, deprecated way: getdir
    #def getdir(ctx,path,filler)
    #  d=@root.search(path)
    #  if d.isdir then
    #    d.each {|name,obj| 
    #      # Use push_old to add this entry, no need for Stat here
    #      filler.push_old(name, obj.mode, 0)
    #    }
    #  else
    #    raise Errno::ENOTDIR.new(path)
    #  end
    #end

    # The new readdir way, c+p-ed from getdir
    def readdir(ctx,path,filler,offset,ffi)
      d=@root.search(path)
      if d.isdir then
        d.each {|name,obj| 
          stat = DtellaFS::Stat.new
          stat.uid   = obj.uid
          stat.gid   = obj.gid
          stat.mode  = obj.mode
          stat.size  = obj.size
          stat.atime = obj.actime
          stat.mtime = obj.modtime
          filler.push(name,stat,0)
        }
      else
        raise Errno::ENOTDIR.new(path)
      end
    end

    def getattr(ctx,path)
      d = @root.search(path)
      stat = Stat.new
      stat.uid   = d.uid
      stat.gid   = d.gid
      stat.mode  = d.mode
      stat.size  = d.size
      stat.atime = d.actime
      stat.mtime = d.modtime
      return stat
    end #getattr

    def mkdir(ctx,path,mode)
      @root.insert_obj(DtellaFS::Dir.new(::File.basename(path),mode),path)
    end #mkdir

    def mknod(ctx,path,mode,dev)
      @root.insert_obj(DtellaFS::File.new(::File.basename(path),mode,ctx.uid,ctx.gid),path)
    end #mknod

    def open(ctx,path,ffi)
    end

    #def release(ctx,path,fi)
    #end

    #def flush(ctx,path,fi)
    #end

    def chmod(ctx,path,mode)
      d=@root.search(path)
      d.mode=mode
    end

    def chown(ctx,path,uid,gid)
      d=@root.search(path)
      d.uid=uid
      d.gid=gid
    end

    def truncate(ctx,path,offset)
      d=@root.search(path)
      d.content = d.content[0..offset]
    end

    def utime(ctx,path,actime,modtime)
      d=@root.search(path)
      d.actime=actime
      d.modtime=modtime
    end

    def unlink(ctx,path)
      @root.remove_obj(path)
    end

    def rmdir(ctx,path)
      @root.remove_obj(path)
    end

    #def symlink(ctx,path,as)
    #end

    def rename(ctx,path,as)
      d = @root.search(path)
      @root.remove_obj(path)
      @root.insert_obj(d,path)
    end

    #def link(ctx,path,as)
    #end

    def read(ctx,path,size,offset,fi)
      d = @root.search(path)
      if (d.isdir) 
        raise Errno::EISDIR.new(path)
        return nil
      else
        return d.content[offset..offset + size - 1]
      end
    end

    def write(ctx,path,buf,offset,fi)
      d=@root.search(path)
      if (d.isdir) 
        raise Errno::EISDIR.new(path)
      else
        d.content[offset..offset+buf.length - 1] = buf
      end
      return buf.length
    end

    def setxattr(ctx,path,name,value,size,flags)
      d=@root.search(path)
      d.setxattr(name,value,flags)
    end

    def getxattr(ctx,path,name,size)
      d=@root.search(path)
      if (d) 
        value=d.getxattr(name)
        if (!value)
          value=""
          #raise Errno::ENOENT.new #TODO raise the correct error :
          #NOATTR which is not implemented in Linux/glibc
        end
      else
        raise Errno::ENOENT.new
      end
      return value
    end

    def listxattr(ctx,path,size)
      d=@root.search(path)
      value= d.listxattr()
      return value
    end

    def removexattr(ctx,path,name)
      d=@root.search(path)
      d.removexattr(name)
    end

    #def opendir(ctx,path,ffi)
    #end

    #def releasedir(ctx,path,ffi)
    #end

    #def fsyncdir(ctx,path,meta,ffi)
    #end

    # Some random numbers to show with df command
    def statfs(ctx,path)
      s = DtellaFS::StatVfs.new
      s.f_bsize    = 1024
      s.f_frsize   = 1024
      s.f_blocks   = 1000000
      s.f_bfree    = 500000
      s.f_bavail   = 990000
      s.f_files    = 10000
      s.f_ffree    = 9900
      s.f_favail   = 9900
      s.f_fsid     = 23423
      s.f_flag     = 0
      s.f_namemax  = 10000
      return s
    end

    def init(ctx,rfuseconninfo)
      print "init called\n"
      print "proto_major: "
      print rfuseconninfo.proto_major
      print "\n"
      return nil
    end
  end
end
