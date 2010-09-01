require 'backup_man/backup'
require 'backup_man/command'

module BackupMan  
  class Rsync < Backup

    # options for the rsync run (DSL)
    def_dsl_required :backup
    
    def_dsl :options
    def_dsl_required :options

    def set_defaults
      @backup_directory = "#{BackupMan.instance.destdir}/#{@name}/rsync" unless @backup_directory
      super
      @options  = "-azR --delete" unless @options
    end

    def _run
      if super
        @data_sources.each do |dir|
          Command.new("rsync #{@options} -e '#{BackupMan.instance.ssh_app}' '#{@user}@#{@host}:#{dir}' '#{@backup_directory}'").run
        end
      end
    end


  end
end