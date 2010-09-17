begin
  require 'fusefs'
rescue LoadError
  require File.expand_path('../../vendor/fusefs/lib/fusefs', __FILE__)
end

module DCFS
  autoload :NickDirectory, 'dcfs/nick_directory'
  autoload :Root, 'dcfs/root'
  autoload :DCFile, 'dcfs/dc_file'
  autoload :VERSION, 'dcfs/version'
end
