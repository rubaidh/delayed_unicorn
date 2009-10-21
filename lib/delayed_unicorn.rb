require 'active_support'

module DelayedUnicorn
  autoload :Launcher,      'delayed_unicorn/launcher'
  autoload :Configuration, 'delayed_unicorn/configuration'

  VERSION = File.read(File.join(File.dirname(__FILE__), '..', 'VERSION')).strip
end
