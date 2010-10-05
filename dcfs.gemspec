# -*- encoding: utf-8 -*-

require File.expand_path('../lib/dcfs/version', __FILE__)

Gem::Specification.new do |s|
  s.name     = 'dcfs'
  s.version  = DCFS::VERSION
  s.platform = Gem::Platform::RUBY

  s.author      = 'Alex Crichton'
  s.homepage    = 'http://github.com/alexcrichton/dcfs'
  s.email       = 'alex@alexcrichton.com'
  s.description = 'DCFS'
  s.summary     = 'A FUSE filesystem backed by the DC protocol'

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files -- bin`.split("\n").map{ |f| File.basename(f) }
  s.extensions   = ['vendor/fusefs/ext/extconf.rb']
  s.rdoc_options = ['--charset=UTF-8']
  s.require_path = 'lib'

  s.add_runtime_dependency 'fargo'
  s.add_runtime_dependency 'activesupport', '>= 3.0.0'
end
