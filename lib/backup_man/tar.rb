require 'backup_man/backup'
require 'backup_man/command'
require 'backup_man/dsl'

module BackupMan
  class Tar < Backup

    def_dsl_required :backup
    
    def_dsl :filename
    def_dsl_required :filename
    
    def_dsl :options
    def_dsl_required :options
    
    def set_defaults
      super
      @filename = "#{Date.today}-files.tgz"
      @options  = "zP"
    end
    
    def _run
      if super
        remote_cmd = "tar -c#{@options}f - ", @data_sources.join(" ")
        Command.new("#{ssh_connect_cmd} #{remote_cmd} > '#{@backup_directory}/#{@filename}'").run
      end
    end
    
    # returns true if the backup already exists
    def exists?
      File.exists? "#{@backup_directory}/#{@filename}"
    end
    

  end
end