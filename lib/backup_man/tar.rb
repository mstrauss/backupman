require 'backup_man/backup'
require 'backup_man/command'
require 'backup_man/dsl'

module BackupMan
  class Tar < Backup

    def_dsl :filename
    def_dsl :options
    
    def set_defaults
      super
      @filename = "#{Date.today}-files.tgz"
      @options  = "zP"
    end
    
    def _run
      remote_cmd = "tar -c#{@options}f - ", @data_sources.join(" ")
      Command.new("#{ssh_connect_cmd} #{remote_cmd} > '#{@backup_directory}/#{@filename}'").run
    end
    
    # returns true if the backup already exists
    def exists?
      File.exists? "#{@backup_directory}/#{@filename}"
    end
    

  end
end