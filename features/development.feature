Feature: Development processes of BackupMan itself (rake tasks)

  As a BackupMan maintainer or contributor
  I want rake tasks to maintain and release the gem
  So that I can spend time on the tests and code, and not excessive time on maintenance processes
    
  Scenario: Generate RubyGem
    Given this project is active project folder
    And "pkg" folder is deleted
    When I invoke task "rake build"
    Then folder "pkg" is created
    And file with name matching "pkg/*.gem" is created
    # And gem spec key "rdoc_options" contains /--mainREADME.rdoc/

  Scenario: Test specs
    Given this project is active project folder
    When I invoke task "rake spec"
    Then I should see all 2 examples pass
