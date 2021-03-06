require 'fargo'

begin
  require 'fusefs'
rescue LoadError
  require File.expand_path('../../vendor/fusefs/lib/fusefs', __FILE__)
end

module DCFS
  autoload :DCFile,        'dcfs/dc_file'
  autoload :NickDirectory, 'dcfs/nick_directory'
  autoload :Root,          'dcfs/root'
  autoload :VERSION,       'dcfs/version'
end
