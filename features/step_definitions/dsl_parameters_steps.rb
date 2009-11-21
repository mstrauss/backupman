# Given /^the parameters "([^\"]*)" are present for "([^\"]*)" in "([^\"]*)"$/ do |parameters, task, configfile|
#   parameters = parameters.split(",")
#   # build_config_file( configfile, task, parameters )
# end

def defaults
  {
    "onlyif" => "'true'",
    "backup" => "['/']",
    "to"     => "'to'",
    "user"   => "'user'",
    "host"   => "'host'",
    "filename" => "'filename'",
    "options"  => "'options'"
  }
end

Given /^the task is "([^\"]*)"$/ do |task|
  @subject = task
end

Given /^the parameters are "([^\"]*)"$/ do |parameters|
  @parameters = parameters.split(",").map{ |p| p.strip }
end

Given /^that goes into configuration file "([^\"]*)"$/ do |configfile|
  f = File.open(configfile, "w") do |f|
    f.puts "#{@subject}.new('test') do |b|"
    @parameters.each { |par| f.puts "  b.#{par} #{defaults[par]}"}
    f.puts "end"
  end
  # puts `cat configuration_file`
end

When /^I start BackupMan with "([^\"]*)"$/ do |commandline|
  cmd = "ruby #{Pathname(__FILE__).parent}/../../bin/backup_man #{commandline}"
  @output = `#{cmd} 2>&1`
  @exit_code = $?
end

Then /^the result should be ok$/ do
  @output.should == ""
  @exit_code.should == 0
end

Then /^the result should be error$/ do
  @output.should_not == ""
  # @exit_code.should_not == 0
end

Then /^the result should be fatal$/ do
  @output.should_not == ""
  @exit_code.should_not == 0
end

Then /^the result should be error "([^\"]*)"$/ do |error|
  @output.should include error
  # @exit_code.should_not == 0
end

Then /^the result should be fatal "([^\"]*)"$/ do |error|
  @output.should include error
  @exit_code.should_not == 0
end
