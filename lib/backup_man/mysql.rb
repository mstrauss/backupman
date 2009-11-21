require 'backup_man/backup'
require 'backup_man/command'

module BackupMan  
  class Mysql < Backup

    # we need a name for our backup-file (DSL)
    def_dsl :filename
    def_dsl_required :filename
    
    # options for the mysqldump run (DSL)
    def_dsl :options
    def_dsl_required :options

    def set_defaults
      super
      @filename = "#{Date.today}-mysqlfull.sql.gz"
      @options  = '--all-databases -u root'
    end

    def _run
      remote_cmd = "mysqldump #{@options}"
      Command.new("#{ssh_connect_cmd} '#{remote_cmd} | gzip' > '#{@backup_directory}/#{@filename}'").run
    end

    # returns true if the backup already exists
    def exists?
      File.exists? "#{@backup_directory}/#{@filename}"
    end

  end
end