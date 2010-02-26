require 'backup_man/backup'
require 'backup_man/command'

module BackupMan
  
  # DSL class for tidying up a local directory
  class Tidy

    # the name of our tidy set; this is used for generating a default
    # directory (the same logic as in the Backup class)
    attr_reader   :name

    # what directory should be tidied
    attr_reader   :directory
        
    # DSL stuff
    include DSL    
    def_dsl :onlyif
    def_dsl_required :onlyif

    def_dsl :directory
    
    def_dsl :zero_byte_files
    def_dsl :keep
    def_dsl :dry_run


    def set_defaults
      @directory = Backup.make_default_backup_directory( @name ) unless @directory
      @onlyif = "true" if @onlyif.nil?
    end

    # yields the block which comes from the DSL configuration file; also
    # registers the new task with {BackupMan}
    def initialize( name )
      @name = name
      yield(self) if block_given?
      BackupMan.instance.register_backup( self )
    end


    private
    
    def _run
      true
    end


  end
end