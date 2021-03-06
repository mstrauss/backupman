Feature: The DSL supports various parameters
  
  Scenario Outline: Presence of DSL parameters
    Given the task is "<task>"
	And the constant "LOCKDIR" is "\"/tmp/locks\""
    And the parameters are "<parameters>"
    And that goes into file "tmp/configuration_file"
    And this project is active project folder
    When I run project executable "./bin/backup_man" with arguments "-l tmp/logfile -t tmp/configuration_file"
    Then the result should be <result>
    
    Scenarios: full set, all parameters are provided and existent (valid)
      | task  | parameters                                        | result |
      | Tar   | onlyif, backup, to, user, host, filename, options | ok     |
      | Mysql | onlyif, backup, to, user, host, filename, options | ok     |
      | Rsync | onlyif, backup, to, user, host,           options | ok     |
    
    Scenarios: full set, but invalid parameters are present
      | task  | parameters                                                           | result                                       |
      | Tar   | onlyif, backup, to, user, host, filename, options, invalid_parameter | fatal "undefined method `invalid_parameter'" |
      | Mysql | onlyif, backup, to, user, host, filename, options, invalid_parameter | fatal "undefined method `invalid_parameter'" |
      | Rsync | onlyif, backup, to, user, host,           options, invalid_parameter | fatal "undefined method `invalid_parameter'" |
   
    Scenarios: minimal set, all required parameters are provided
      | task  | parameters  | result |
      | Tar   | backup      | ok     |
      | Mysql |             | ok     |
      | Rsync | backup      | ok     |
  
    Scenarios: one required parameter is missing
      | task  | parameters                                | result                                          |
      | Tar   | onlyif, to, user, host, filename, options | error "A required parameter is missing: backup" |
      | Rsync | onlyif, to, user, host, options           | error "A required parameter is missing: backup" |
  
