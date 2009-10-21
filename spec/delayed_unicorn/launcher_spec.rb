require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DelayedUnicorn::Launcher do
  it "should run with no arguments" do
    lambda { DelayedUnicorn::Launcher.run! }.should_not raise_error
  end

  describe "command line parsing" do

    it "should parse the supplied command line arguments using OptionParser" do
      dummy_option_parser = mock(OptionParser)
      OptionParser.stub!(:new).and_return(dummy_option_parser)
      dummy_option_parser.should_receive(:parse!).with(["some", "arguments", "supplied", "on", "the", "command", "line"])

      launcher = DelayedUnicorn::Launcher.run! "some", "arguments", "supplied", "on", "the", "command", "line"
    end

    it "should not daemonize by default (no '-D' argument specified)" do
      launcher = DelayedUnicorn::Launcher.run!
      launcher.options[:daemonize].should be_false
    end

    it "should enable daemonization if passed '-D' or '--daemonize'" do
      undaemonizable_launcher = DelayedUnicorn::Launcher.new '-D'
      undaemonizable_launcher.should_receive(:daemonize!)
      undaemonizable_launcher.run!
      undaemonizable_launcher.options[:daemonize].should be_true

      undaemonizable_launcher = DelayedUnicorn::Launcher.new '--daemonize'
      undaemonizable_launcher.should_receive(:daemonize!)
      undaemonizable_launcher.run!
      undaemonizable_launcher.options[:daemonize].should be_true
    end

    it "should default the environment to 'development' if no environment is specified" do
      launcher = DelayedUnicorn::Launcher.run!
      launcher.options[:environment].should == "development"
    end

    it "should allow you to specify an environment with the '-E' flag" do
      launcher = DelayedUnicorn::Launcher.run! "-E", "desert"
      launcher.options[:environment].should == "desert"
    end

    it "should require an environment to be specified if the '-E' argument is supplied" do
      lambda {
        DelayedUnicorn::Launcher.run! "-E"
      }.should raise_error(OptionParser::MissingArgument)
    end
  end

  it "should daemonize correctly if told to do so." do
    pending "I have no idea how to test the daemonizing is actually happenning correctly. Anyone?"
  end
end
