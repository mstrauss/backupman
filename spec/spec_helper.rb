$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'backup_man'
require 'backup_man/cli'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  
  config.before do
    Log = mock("logger") unless defined? Log
    @log = mock("logger instance")
    @log.stub(:debug)
    Log.stub(:instance).and_return(@log)
  end
  
end
