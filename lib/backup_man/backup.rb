require 'backup_man/backup_man'
require 'backup_man/dsl'

module BackupMan

  def self.log_end_of_operation
    Log.info( "Finished #{self}." )
  end

  # we wanna log when the program ends
  at_exit { self.log_end_of_operation }


  # References: _Design Patterns in Ruby_ by Russ Olsen
  class Backup

    # the name of our backup set; this is used for generating a default
    # backup_directory; e.g. use the hostname of the machine to backup
    attr_reader   :name

    # where shall our backup data go (directory path)
    attr_reader   :backup_directory

    # user name of the remote machine (defaults to 'root')
    attr_accessor :user

    # hostname of the remote machine (defaults to job definition name)
    attr_accessor :host

    # DSL for conditional execution
    include DSL

    def_dsl :onlyif
    def_dsl_required :onlyif

    def_dsl :backup, :data_sources
    def_dsl :to, :backup_directory, true
    def_dsl :user, :user, true
    def_dsl :host, :user, true


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

    # yields the block which comes from the DSL configuration file; also
    # registers the new backup configuration with {BackupMan}
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
      debug_log_dsl_info
      unless missing_required_parameters.empty?
        Log.error( "#{self}: A required parameter is missing: #{missing_required_parameters.join ' '}")
        return
      end
      onlyif = eval( @onlyif )
      Log.debug( "onlyif = { #{@onlyif} } evaluates #{onlyif}" )
      if onlyif
        unless @backup_directory
          Log.error( "#{self}: No backup directory. Don't know where to store all this stuff.")
        else
          FileUtils.mkdir_p @backup_directory
          _run
        end
      else
        Log.info( "#{self}: Preconditions for backup run not fulfilled.")
      end
      log_end_of_run
    end

    # @return [String]
    def to_s
      "#{self.class} #{self.name}"
    end



    private

    # @abstract override this to implement the actual backup commands
    def _run
      throw "Hey. Cannot run just 'Backup'."
    end

    # @returns [Array of Strings] of missing parameters
    def missing_required_parameters
      missing = []
      self.class.dsl_methods.each do |name, var, mandatory|      
        missing << name if mandatory && self.instance_variable_get("@#{var}").empty?
      end
      missing
    end

    # not used acutally
    def log_begin_of_run
      Log.info( "Starting #{self.class} run for #{@name}." )
    end

    # simply logs that the program terminates
    def log_end_of_run
      Log.info( "Finished #{self.class} run for #{@name}." )
    end

    # @return [String] the ssh command string including user@host
    def ssh_connect_cmd
      "#{BackupMan.instance.ssh_app} #{@user}@#{@host}"  
    end

  end
end