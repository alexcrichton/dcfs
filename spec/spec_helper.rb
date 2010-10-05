require 'rubygems'
require 'bundler/setup'

require 'rspec/core'
require 'dcfs'

Fargo.logger.level = ActiveSupport::BufferedLogger::WARN

RSpec.configure do |c|
  c.color_enabled = true
end
