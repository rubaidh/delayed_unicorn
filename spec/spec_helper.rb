$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'delayed_unicorn'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  
end
