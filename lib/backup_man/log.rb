require 'singleton'
require 'delegate'
require 'rubygems'
require 'log4r'

module BackupMan

  # = Singleton logger
  #
  # This one logs INFO and higher to a file and WARN and higher to STDERR. It
  # does this by creating a new Log4r::Logger object and configuring it.
  # SimpleDelegator wrapps this.
  #  
  # By default, the logfile goes into workdir/backup_man.log. To override use
  # LOGFILE in the backup case definition.
  #
  # == References
  # * http://www.5dollarwhitebox.org/drupal/ruby_dual_output_logging
  # * http://rubyforge.org/snippet/detail.php?type=snippet&id=146
  #   
  class Log < SimpleDelegator
    include Singleton
    include Log4r

    def initialize
      @logger = Logger.new( "BackupMan" )
      super( @logger )

      console_format = PatternFormatter.new(:pattern => "%l:\t %m")
      stderr_outputter = Log4r::StderrOutputter.new( 'console', :formatter => console_format )
      stderr_outputter.level = WARN
      @logger.add stderr_outputter

      if filename = BackupMan.instance.logfile
        file_format = PatternFormatter.new(:pattern => "[ %d ] %l\t %m")
        file_outputter = FileOutputter.new('fileOutputter', :filename => filename, :trunc => false, :formatter => file_format )
        file_outputter.level = DEBUG
        @logger.add file_outputter
      end
    end
    
    def enable_debugmode
      Log4r::Outputter.each_outputter { |outputter| outputter.level = DEBUG }
    end

  end

end