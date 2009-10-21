require 'optparse'

class DelayedUnicorn::Launcher
  def self.run!(*argv)
    new(*argv).run!
  end

  attr_accessor :arguments, :options

  def initialize(*argv)
    self.arguments = argv

    self.options = {
      :environment => "development",
      :daemonize   => false
    }
  end

  def run!
    setup_stdio!
    parse_arguments!

    daemonize! if options.delete(:daemonize)
  end

  private

  def stdio_channels
    [$stdin, $stdout, $stderr]
  end

  def setup_stdio!
    stdio_channels.each do |ch|
      ch.sync = true
      ch.binmode
    end
  end

  def parse_arguments!
    opts = OptionParser.new do |opts|
      opts.banner = "Usage: #{progname} [ruby options] [delayed unicorn options]"

      opts.separator "Ruby options:"

      lineno = 1
      opts.on("-e", "--eval LINE", "evaluate a LINE of code") do |line|
        eval line, TOPLEVEL_BINDING, "-e", lineno
        lineno += 1
      end

      opts.on("-d", "--debug", "set debugging flags (set $DEBUG to true)") do
        $DEBUG = true
      end

      opts.on("-w", "--warn", "turn warnings on for your script") do
        $-w = true
      end

      opts.on("-I", "--include PATH",
              "specify $LOAD_PATH (may be used more than once)") do |path|
        $LOAD_PATH.unshift(*path.split(/:/))
      end

      opts.on("-r", "--require LIBRARY",
              "require the library, before executing your script") do |library|
        require library
      end

      opts.separator "Delayed Unicorn options:"

      opts.on("-E", "--environment ENVIRONMENT",
              "use ENVIRONMENT for defaults (default: #{options[:environment]})") do |e|
        options[:environment] = e
      end

      opts.on("-D", "--daemonize", "run daemonized in the background") do |d|
        options[:daemonize] = d ? true : false
      end

      opts.on("-c", "--config-file FILE", "Unicorn-specific config file") do |f|
        options[:config_file] = File.expand_path(f)
      end

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts.to_s.gsub(/^.*DEPRECATED.*$/s, '')
        exit
      end

      opts.on_tail("-v", "--version", "Show version") do
        puts "Delayed Unicorn v#{DelayedUnicorn::VERSION}"
        exit
      end
    end
    opts.parse! arguments
  end

  # The usual daemonization nonsense -- fork, create a new process group and
  # fork again, which should free us from our controllering terminal like a
  # good divorce lawyer. As with Unicorn, we're not messing with the umask or
  # changing directory (for now, at least).
  #
  # FIXME: Review whether we should be chdir("/")ing. We'll always chdir() to
  # the APP_ROOT and it's unlikely that you'll want to unmount that dir at any
  # point.
  #
  # FIXME: Review whether keeping existing umask or making it a (conserative)
  # "known good" is the right way forward.
  def daemonize!
    $stdin.reopen("/dev/null")
    exit if fork
    Process.setsid
    exit if fork

    setup_stdio!
  end

  def progname
    File.basename($0)
  end
end
