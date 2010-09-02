begin
  require 'rfuse-ng'
rescue LoadError
  require File.expand_path('../../vendor/rfuse-ng/ext/rfuse_ng', __FILE__)
end

module DtellaFS
  autoload :File, 'dtellafs/file'
  autoload :Dir, 'dtellafs/dir'
  autoload :Stat, 'dtellafs/stat'
  autoload :StatVfs, 'dtellafs/stat_vfs'
  autoload :Fuse, 'dtellafs/fuse'
  autoload :VERSION, 'dtellafs/version'
end