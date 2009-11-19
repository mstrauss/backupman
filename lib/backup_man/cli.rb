require 'optparse'
require 'date'
require 'pathname'

require_relative 'log'
require_relative 'tar'
require_relative 'rsync'
require_relative 'mysql'


module BackupMan
  class CLI
    def self.execute(stdout, arguments=[])

      # NOTE: the option -p/--path= is given as an example, and should be replaced in your application.

      options = {
        :debug     => false,
        :logpath   => '/var/log/backup_man.log'
      }
      mandatory_options = %w(  )

      parser = OptionParser.new do |opts|
        opts.banner = <<-BANNER.gsub(/^          /,'')
          BackupMan handles your SSH-pull-style backups. Call this program regularily via cron in the security space of your favorite user account. This account 

          Usage: #{File.basename($0)} [options] {configname | configpath}

          Options are:
        BANNER
        opts.separator ""
        opts.on("-l", "--logpath=PATH", String,
                "Path to the log file. This can NOT be configured in the config file.",
                "Default: /var/log/backup_man.log") { |arg| options[:logpath] = arg }
        opts.on("-d", "--debug", "Debug mode.", "Much output on screen and in the log file." ) {
          options[:debug] = true
        }
        opts.on("-h", "--help",
                "Show this help message.") { stdout.puts opts; exit }
        opts.parse!(arguments)

        if mandatory_options && mandatory_options.find { |option| options[option.to_sym].nil? }
          stdout.puts opts; exit
        end
      end

      # doing our stuff here
      BackupMan.instance.logfile = options[:logpath]
      
      # root-warning
      Log.instance.warn( "Please do not run this program as root.") if `id -u`.strip == '0'

      # reconfigure our Logger for debugging if necessary
      if options[:debug]
        Log.instance.enable_debugmode
        Log.instance.debug( "Debugging mode enabled.")
      end
      

      unless ARGV[0]
        Log.instance.fatal( "No config file given." )
        stdout.puts parser
        exit 1
      else
        config_filepath = Pathname.new( ARGV[0] )
        config_filepath = Pathname.new "/etc/backup_man/#{config_filepath}" unless config_filepath.file?
        
        unless config_filepath.file?
          Log.instance.fatal( "Config file not found [#{config_filepath}].")
          exit 2
        end

        # get and evaluate the config file; errors in the config file may be
        # difficult to debug, so be careful
        Log.instance.debug( "Reading file '#{config_filepath}'.")
        eval( File.read( config_filepath ) )

        # configure global defaults
        BackupMan.instance.set_default( :destdir, '/var/backups/backup_man')
        BackupMan.instance.set_default( :lockdir, '/var/lock/backup_man')
        BackupMan.instance.set_default( :ssh_app, 'ssh')
        
        Log.instance.debug( "Global settings:")
        Log.instance.debug( "  DESTDIR = #{BackupMan.instance.destdir}")
        Log.instance.debug( "  LOCKDIR = #{BackupMan.instance.lockdir}")
        Log.instance.debug( "  SSH_APP = #{BackupMan.instance.ssh_app}")

        # run the whole thing
        BackupMan.instance.run
      end
      
    end
  end
end