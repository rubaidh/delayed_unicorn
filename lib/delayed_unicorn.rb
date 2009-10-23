require 'active_support'

module DelayedUnicorn
  autoload :Process,       'delayed_unicorn/process'
  autoload :Master,        'delayed_unicorn/master'
  autoload :Worker,        'delayed_unicorn/worker'
  autoload :Launcher,      'delayed_unicorn/launcher'
  autoload :Configuration, 'delayed_unicorn/configuration'

  VERSION = File.read(File.join(File.dirname(__FILE__), '..', 'VERSION')).strip
end
