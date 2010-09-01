require 'backup_man/backup_man'
require 'backup_man/dsl'
require 'fileutils'

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
    def_dsl :host, :host, true


    # this method sets all the default values but does not overwrite existing
    # settings; this method cannot be called in the initializer of Backup
    # because the default values are not available at that time;
    def set_defaults
      @data_sources = [] unless @data_sources
      @backup_directory = Backup.make_default_backup_directory(@name) unless @backup_directory
      @onlyif = "true" if @onlyif.nil?
      @user = 'root' unless @user
      @host = @name unless @host
    end
    
    # DRY method for creating the default backup directory. Also used for
    # creating the default tidy directory.
    def self.make_default_backup_directory( name )
      "#{BackupMan.instance.destdir}/#{name}"
    end


    private
    
    def _run
      # checking if we have the backup_directory      
      unless @backup_directory
        Log.error( "#{self}: No backup directory. Don't know where to store all this stuff.")
        return false
      else
        FileUtils.mkdir_p @backup_directory
        return true
      end
    end
    
    # @return [String] the ssh command string including user@host
    def ssh_connect_cmd
      "#{BackupMan.instance.ssh_app} #{@user}@#{@host}"  
    end

  end
end