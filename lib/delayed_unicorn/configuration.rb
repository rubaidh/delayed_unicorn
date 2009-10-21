require 'logger'

class DelayedUnicorn::Configuration

  # Default options
  DEFAULTS = {
    :logger           => Logger.new($stderr),
    :environment      => "development",
    :worker_processes => 1,
    :after_fork       => lambda { |server, worker|
      server.logger.info("Worker #{worker.inspect} spawned (pid=#{$$})")
    },
    :before_fork      => lambda { |server, worker|
      server.logger.infor("Worker #{worker.inspect} spawning...")
    },
    :before_exec      => lambda { |server|
      server.logger.info("Forked child re-executing...")
    }
  }

  attr_accessor :set, :config_file

  def initialize(options = {})
    options.symbolize_keys!

    self.set = Hash.new(:unset)
    set.merge!(DEFAULTS) if options.delete(:use_defaults)
    self.config_file = options.delete(:config_file)

    options.each do |key, value|
      send(key, value)
    end

    reload
  end

  def reload
    instance_eval(File.read(config_file), config_file) if config_file
  end

  def [](key)
    set[key.to_sym]
  end

  def logger(new_logger)
    # Verify we've got something that walks, talks and quacks like a logger
    # well enough for our purposes.
    %w(debug info warn error fatal close).each do |m|
      raise ArgumentError, "Logger #{new_logger} does not respond to #{m}" unless new_logger.respond_to?(m)
    end

    set[:logger] = new_logger
  end

  def environment(new_environment)
    set[:environment] = new_environment
  end

  def worker_processes(new_worker_processes)
    raise ArgumentError, "worker_processes is not an integer" unless new_worker_processes.is_a?(Integer)
    raise ArgumentError, "worker_processes is not greater than one (you want at least one worker, right?)" unless new_worker_processes > 0

    set[:worker_processes] = new_worker_processes
  end

  def pidfile_path(path)
    set_path(:pidfile_path, path)
  end

  def stderr_path(path)
    set_path(:stderr_path, path)
  end

  def stdout_path(path)
    set_path(:stdout_path, path)
  end

  def before_fork(*args, &block)
    set_hook(:before_fork, :block_given? ? block : args[0], 2)
  end

  def after_fork(*args, &block)
    set_hook(:after_fork, :block_given? ? block : args[0], 2)
  end

  def before_exec(*args, &block)
    set_hook(:before_exec, :block_given? ? block : args[0], 1)
  end

  private
  def set_path(var, path)
    case path
    when NilClass
      # FIXME: What's the difference, semantically, between a path set to nil
      # and a path set to :unset?
      path = :unset
    when String
      path = File.expand_path(path)
      raise ArgumentError, "Directory for #{var} file, #{path} is not writable" unless File.writable?(File.dirname(path))
    else
      raise ArgumentError
    end
    set[var] = path
  end

  def set_hook(hook, block_or_nil, arity)
    case block_or_nil
    when Proc
      block_arity = block_or_nil.arity
      raise ArgumentError, "Incorrect number of arguments supplied (#{block_arity} for #{arity})" unless block_arity == arity
    when NilClass
      block_or_nil = DEFAULTS[hook]
    else
      raise ArgumentError, "Invalid type for hook #{hook}: #{block_or_nil.insepct}"
    end

    set[hook] = block_or_nil
  end
end
