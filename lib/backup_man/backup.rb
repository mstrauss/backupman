require 'backup_man/backup_man'
require 'backup_man/dsl'

module BackupMan

  def self.log_end_of_operation
    Log.instance.info( "Finished #{self}." )
  end

  at_exit { self.log_end_of_operation }


  # References: _Design Patterns in Ruby_ by Russ Olsen
  class Backup
    
    # the name of our backup set; this is used for generating a default
    # backup_directory; e.g. use the hostname of the machine to backup
    attr_reader   :name
    
    # where shall our backup data go (directory path)
    attr_reader   :backup_directory
    
    # by the way, what machine do we backup
    attr_accessor :user, :host
    
    # DSL for conditional execution
    self.extend DSL
    
    def_dsl :onlyif
    def_dsl :backup, :data_sources
    def_dsl :to, :backup_directory
    def_dsl :user
    def_dsl :host
    
    
    # this method sets all the default values but does not overwrite existing
    # settings; this method cannot be called in the initializer of Backup
    # because the default values are not available at that time;
    def set_defaults
      @data_sources = [] unless @data_sources
      @backup_directory = "#{BackupMan.instance.destdir}/#{@name}" unless @backup_directory
      @onlyif = "true" if @onlyif.nil?
      @user = 'root' unless @user
      @host = @name unless @host
    end

    def initialize( name )
      @name = name      
      yield(self) if block_given?
      BackupMan.instance.register_backup( self )
    end
    
    # calling this actually runs the backup; DO NOT override this; override
    # _run instead
    def run
      log_begin_of_run
      set_defaults
      onlyif = eval( @onlyif )
      Log.instance.debug( "onlyif = { #{@onlyif} } evaluates #{onlyif}" )
      if onlyif
        # Log.instance.warn( "#{self}: No data sources given.") unless @data_sources && !@data_sources.empty?
        unless @backup_directory
          Log.instance.error( "#{self}: No backup directory. Don't know where to store all this stuff.")
        else
          FileUtils.mkdir_p @backup_directory
          _run
        end
      else
        Log.instance.info( "#{self}: Preconditions for backup run not fulfilled.")
      end
      log_end_of_run
    end
    
    def to_s
      "#{self.class} #{self.name}"
    end


    
    private
    
    # this one must be overridden
    def _run
      throw "Hey. Cannot run just 'Backup'."
    end
    
    def log_begin_of_run
      Log.instance.info( "Starting #{self.class} run for #{@name}." )
    end
    
    def log_end_of_run
      Log.instance.info( "Finished #{self.class} run for #{@name}." )
    end

    def ssh_connect_cmd
      "#{BackupMan.instance.ssh_app} #{@user}@#{@host}"  
    end

  end
end