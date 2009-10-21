require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DelayedUnicorn::Configuration do
  it "should successfully initialize" do
    lambda {
      DelayedUnicorn::Configuration.new
      }.should_not raise_error
  end

  it "should successfully initialize using the defaults" do
    lambda {
      DelayedUnicorn::Configuration.new(:use_defaults => true)
    }.should_not raise_error
  end

  it "should not set any default values if not called with :use_defaults" do
    configuration = DelayedUnicorn::Configuration.new

    configuration[:environment].     should be_unset
    configuration[:worker_processes].should be_unset
  end

  it "should yield the default values if called with :use_defaults" do
    configuration = DelayedUnicorn::Configuration.new :use_defaults => true

    configuration[:environment].     should == "development"
    configuration[:worker_processes].should == 1
  end

  it "should allow defaults to be overridden by passing in options" do
    configuration = DelayedUnicorn::Configuration.new :use_defaults => true, :environment => "production"

    configuration[:environment].should == "production"
  end

  describe "reading from a config file" do
    def replace_config_file_with(str)
      @config_file.open
      @config_file.write str
      @config_file.close
    end

    before(:each) do
      @config_file = Tempfile.new("delayed_unicorn.rb")
      @config_file.close

      # Provide a sensible default config file for the rest of the specs
      replace_config_file_with <<-CONFIG
        environment      "production"
        worker_processes 3
      CONFIG
    end

    after(:each) do
      @config_file.close(true)
    end

    # FIXME: This test relies on Dir.tmpdir existing and being writable by the
    # current user. But if it isn't, this spec isn't going to be the only
    # thing that fails in your day. :)
    it "should read the configuration DSL from a file" do
      replace_config_file_with <<-CONFIG
        environment      "read_from_config_file"
        worker_processes 3
        pidfile_path     "#{Dir.tmpdir}/pidfile.pid"
        stderr_path      "#{Dir.tmpdir}/stderr.log"
        stdout_path      "#{Dir.tmpdir}/stdout.log"
      CONFIG

      configuration = DelayedUnicorn::Configuration.new :use_defaults => true, :config_file => @config_file.path

      configuration[:environment].     should == "read_from_config_file"
      configuration[:worker_processes].should == 3
      configuration[:pidfile_path].    should == "#{Dir.tmpdir}/pidfile.pid"
      configuration[:stderr_path].     should == "#{Dir.tmpdir}/stderr.log"
      configuration[:stdout_path].     should == "#{Dir.tmpdir}/stdout.log"
    end

    it "should allow the configuration file to be reloaded and the new content to be applied" do
      configuration = DelayedUnicorn::Configuration.new :use_defaults => true, :config_file => @config_file.path

      replace_config_file_with <<-CONFIG
      environment      "new_config_file_value"
      worker_processes 17
      CONFIG

      configuration.reload

      configuration[:environment].     should == "new_config_file_value"
      configuration[:worker_processes].should == 17
    end
  end

  describe "validating arguments" do
    it "should verify that a logger duck types to a logger (as much as we care)" do
      configuration = DelayedUnicorn::Configuration.new :use_defaults => true

      lambda {
        configuration.logger mock("Invalid logger")
      }.should raise_error(ArgumentError)

      lambda {
        configuration.logger mock("Valid logger", :debug => nil, :info => nil, :warn => nil, :error => nil, :fatal => nil, :close => nil)
      }.should_not raise_error
    end

    it "should verify that the number of worker_processes is a positive integer" do
      configuration = DelayedUnicorn::Configuration.new :use_defaults => true

      lambda {
        configuration.worker_processes "Chips!"
      }.should raise_error(ArgumentError)

      lambda {
        configuration.worker_processes 2.75
      }.should raise_error(ArgumentError)

      lambda {
        configuration.worker_processes -3
      }.should raise_error(ArgumentError)

      lambda {
        configuration.worker_processes 4
      }.should_not raise_error
    end

    describe "hooks" do
      it "should verify that the proc supplied to after_fork takes two arguments" do
        configuration = DelayedUnicorn::Configuration.new :use_defaults => true

        lambda {
          configuration.after_fork { |one|
            only_takes_one_argument
          }
        }.should raise_error(ArgumentError)

        lambda {
          configuration.after_fork { |one, two, three|
            takes_three_arguments
          }
        }.should raise_error(ArgumentError)

        lambda {
          configuration.after_fork { |one, two|
            takes_two_arguments
          }
        }.should_not raise_error
      end

      it "should verify that the proc supplied to before_fork takes two arguments" do
        configuration = DelayedUnicorn::Configuration.new :use_defaults => true

        lambda {
          configuration.before_fork { |one|
            only_takes_one_argument
          }
        }.should raise_error(ArgumentError)

        lambda {
          configuration.before_fork { |one, two, three|
            takes_three_arguments
          }
        }.should raise_error(ArgumentError)

        lambda {
          configuration.before_fork { |one, two|
            takes_two_arguments
          }
        }.should_not raise_error
      end

      it "should verify that the proc supplied to before_exec takes one argument" do
        configuration = DelayedUnicorn::Configuration.new :use_defaults => true

        lambda {
          configuration.before_exec {
            takes_no_arguments
          }
        }.should raise_error(ArgumentError)

        lambda {
          configuration.before_exec { |one, two, three|
            takes_three_arguments
          }
        }.should raise_error(ArgumentError)

        lambda {
          configuration.before_exec { |one|
            takes_one_argument
          }
        }.should_not raise_error
      end

      it "should revert each hook back to the default if nil is passed in" do
        configuration = DelayedUnicorn::Configuration.new :use_defaults => true

        unary_lambda  = lambda { |a|    a }
        binary_lambda = lambda { |a, b| a }

        configuration.after_fork &binary_lambda
        configuration[:after_fork].should == binary_lambda
        configuration.after_fork nil
        configuration[:after_fork].should == DelayedUnicorn::Configuration::DEFAULTS[:after_fork]

        configuration.before_fork &binary_lambda
        configuration[:before_fork].should == binary_lambda
        configuration.before_fork nil
        configuration[:before_fork].should == DelayedUnicorn::Configuration::DEFAULTS[:before_fork]

        configuration.before_exec &unary_lambda
        configuration[:before_exec].should == unary_lambda
        configuration.before_exec nil
        configuration[:before_exec].should == DelayedUnicorn::Configuration::DEFAULTS[:before_exec]
      end
    end
  end
end
