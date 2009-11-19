
require 'digest/md5'

module BackupMan
  # = Command class
  # This class allows to run commands and makes sure the same command cannot
  # run two times at the same time.
  #  
  # This ensured by creating lockfiles in the working directory. To override
  # define LOCKDIR.

  class Command

    attr_reader :cmd

    def initialize( cmd )
      @cmd = cmd      
    end

    # returns true if the command is locked (= currently running)
    def locked?
      File.exists?( self.lockfile )
    end

    # returns the path to the lockfile for this command
    def lockfile
      hash = Digest::MD5.hexdigest(cmd.to_s)
      BackupMan.instance.build_lockfile_path( "#{hash}.lock.txt" )
    end

    # returns a nice string representation of the command
    def to_s
      self.cmd.to_s
    end

    def run
      unless locked?
        lock
        begin
          Log.instance.info( "#{self}: Running.")
          print `#{cmd}` unless TESTING
        rescue Interrupt
          Log.instance.warn( "#{self}: Operation interrupted.")
          raise
        ensure
          unlock
        end
      else
        Log.instance.warn( "Command already running: #{self}." )
      end
    end


    private

    def lock
      Log.instance.debug( "Locking command " + self.cmd )
      unless locked?
        f = File.new( self.lockfile, "w" )
        # FIXME: command output shall go into the correct logging lvl (eg ERROR)
        f.write(self.cmd)
        f.close
      else
        Log.instance.info( "Lockfile exists: " + lockfile )
      end
    end

    def unlock
      Log.instance.debug( "Unlocking command " + self.cmd )
      FileUtils.remove_file( self.lockfile )
    end

  end
end