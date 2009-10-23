class DelayedUnicorn::Master < DelayedUnicorn::Process
  attr_accessor :config, :before_exec, :before_fork, :after_fork,
    :environment, :logger, :worker_processes

  def initialize(options = {})
    self.config = DelayedUnicorn::Configuration.new options.merge(:use_defaults => true)
    config.commit!(self)
  end

  def start
    self
  end

  def join
  end

  def stop(graceful = true)
  end
end
