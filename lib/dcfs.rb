begin
  require 'fusefs'
rescue LoadError
  $LOAD_PATH << File.expand_path('../../vendor/fusefs/ext', __FILE__)
  require File.expand_path('../../vendor/fusefs/lib/fusefs', __FILE__)
end

module DCFS
  autoload :Root, 'dcfs/root'
  autoload :VERSION, 'dcfs/version'
end