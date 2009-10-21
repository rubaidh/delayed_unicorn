require 'rubygems'

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'delayed_unicorn'

require 'spec'
require 'spec/autorun'
require 'tempfile'
require 'tmpdir'

Spec::Runner.configure do |config|
  
end

Spec::Matchers.define :be_unset do
  match do |configuration_value|
    configuration_value == :unset
  end
end
