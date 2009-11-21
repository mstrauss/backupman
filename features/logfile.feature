Feature: logfile
  In order to have a log of the BackupMan's doings
  BackupMan should write to a logfile
    
  Scenario: the logfile is writable
    Given the logfile is writeable
    And the user has not used option '-h'
    When I start BackupMan
    Then the logfile should become updated
    
  Scenario: the logfile is not writeable
    Given the logfile is not writeable
    And the user has not used option '-h'
    When I start BackupMan
    Then error "logfile not writable" should be printed
    
  Scenario: logfile parameter given, and writeable
    When I start BackupMan with parameter "-l /path/to/logfile"
    And the file "path/to/logfile" is writeable
    Then the logfile should become updated
    
  Scenario: logfile parameter given, and not writeable
    When I start BackupMan with parameter "-l /path/to/logfile"
    And the file "path/to/logfile" is not writeable
    And the directory "path/to" is not writeable
    Then error "logfile not writable" should be printed

  Scenario: no logfile parameter given
    When I start BackupMan
    Then "/var/log/backup_man.log" should be used as the default logfile
