require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "BackupMan"
    gem.summary = %Q{A tool for system administrators to easily configure pull-over-SSH backups.}
    gem.description = %Q{A tool for system administrators to easily configure pull-over-SSH backups. Install this gem on your backup server. Configure your backups definitions in /etc/backup_man and run backup_man from cron to securely pull your data over SSH.}
    gem.email = "Markus@ITstrauss.eu"
    gem.homepage = "http://github.com/oowoo/BackupMan"
    gem.authors = ["Markus Strauss"]
    gem.rubyforge_project = "BackupMan"
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "yard", ">= 0"
    gem.add_dependency "log4r", ">= 1.1.2"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = "yardoc"
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
