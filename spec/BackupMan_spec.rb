require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module BackupMan
  describe "CLI" do

    context "execute" do

      it "should exit cleanly and print usage when -h is used" do
        argv = ["-h"]
        out = StringIO.new
        lambda { ::BackupMan::CLI.execute( out, argv ) }.should raise_error SystemExit
        out.string.should include("Usage: spec [options] {configname | configpath}")
      end
      
      it "should print an error when the log file is not writeable and continue to run cleanly" do
        argv = ["-l", "/tmp/does/not/exist.log"]
        out = StringIO.new
        $stderr = StringIO.new
        lambda { ::BackupMan::CLI.execute( out, argv) }.should_not raise_error SystemExit
        $stderr.string.should include("Log file is not writeable")
      end

    end
  end
end
