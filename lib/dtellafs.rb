begin
  require 'fusefs'
rescue LoadError
  require File.expand_path('../../vendor/fusefs/ext/fusefs_lib', __FILE__)
  require File.expand_path('../../vendor/fusefs/lib/fusefs', __FILE__)
end

module DtellaFS
  autoload :File, 'dtellafs/file'
  autoload :Dir, 'dtellafs/dir'
  autoload :Stat, 'dtellafs/stat'
  autoload :StatVfs, 'dtellafs/stat_vfs'
  autoload :Fuse, 'dtellafs/fuse'
  autoload :VERSION, 'dtellafs/version'
end