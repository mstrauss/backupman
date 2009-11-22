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

Then /^the result should be ok$/ do
  steps %Q{
    Then I should not see any output
    And the exit code should be 0
  }
end

Then /^the result should be error$/ do
  steps %Q{
    Then I should see some output
  }
end

Then /^the result should be fatal$/ do
  steps %Q{
    Then I should see some output
    And the exit code should not be 0
  }
end

Then /^the result should be error "([^\"]*)"$/ do |error|
  steps %Q{
    Then I should see
      """
      #{error}
      """
  }
end

Then /^the result should be fatal "([^\"]*)"$/ do |error|
  steps %Q{
    Then I should see
      """
      #{error}
      """
    And the exit code should not be 0
  }
end

Then /^the exit code (should|should not) be (.+)$/ do |should, code|
  $?.method(:should) == code
end

Then /^Then I should see some output$/ do
  actual_output = File.read(@stdout)
  actual_output.should_not == ""
end

Then /^I should not see any output$/ do
  actual_output = File.read(@stdout)
  actual_output.should == ""
end
