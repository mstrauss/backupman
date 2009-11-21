require 'singleton'

module BackupMan
  # this is a singleton class managing the application; it holds some
  # important global settings, like the global destination directory;
  class BackupMan

    include Singleton
    
    attr_accessor :destdir, :ssh_app, :logfile, :lockdir, :testing

    def initialize
      @backups = []
    end

    def register_backup( backup )
      @backups << backup
    end
    
    def run
      @backups.each do |backup|
        begin
          backup.run
        rescue Interrupt
          Log.instance.warn( "Interrupt: Cancelling remaining operations.")
          return
        end
      end        
    end
    
    def build_lockfile_path( filename )
      "#{@lockdir}/#{filename}"
    end
    
    def set_default( symbol, value )
      const_s = symbol.to_s.upcase
      if CLI.const_defined?( const_s )
        self.instance_variable_set( "@#{symbol.to_s}", CLI.const_get( const_s ) )
      else
        self.instance_variable_set( "@#{symbol.to_s}", value )
      end
    end

  end
end