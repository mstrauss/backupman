
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

Given /^the constant "([^\"]*)" is "([^\"]*)"$/ do |konst,value|
  @constants ||= {}
  @constants[konst] = value
end

Given /^that goes into file "([^\"]*)"$/ do |configfile|
  f = File.open(configfile, "w") do |f|
    # constants first
    @constants.each { |k,v| "#{k} = #{v}" }
    # then the rest
    f.puts "#{@subject}.new('test') do |b|"
    @parameters.each { |par| f.puts "  b.#{par} #{defaults[par]}"}
    f.puts "end"
  end
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
