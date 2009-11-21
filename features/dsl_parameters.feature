Feature: The DSL supports various parameters
  
  Scenario Outline: Presence of DSL parameters
    Given the task is "<task>"
    And the parameters are "<parameters>"
    And that goes into configuration file "configuration_file"
    When I start BackupMan with "-t configuration_file"
    Then the result should be <result>
    
    Scenarios: full set, all parameters are provided and existent (valid)
      | task  | parameters                                        | result |
      | Tar   | onlyif, backup, to, user, host, filename, options | ok     |
      | Mysql | onlyif, backup, to, user, host, filename, options | ok     |
      | Rsync | onlyif, backup, to, user, host,           options | ok     |
    
    Scenarios: full set, but invalid parameters are present
      | task  | parameters        | result |
      | Tar   | onlyif, backup, to, user, host, filename, options, invalid_parameter | error  |
      | Mysql | onlyif, backup, to, user, host, filename, options, invalid_parameter | error  |
      | Rsync | onlyif, backup, to, user, host,           options, invalid_parameter | error  |
  
    Scenarios: minimal set, all required parameters are provided
      | task  | parameters  | result |
      | Tar   | backup      | ok     |
      | Mysql |             | ok     |
      | Rsync | backup      | ok     |
  
    Scenarios: one required parameter is missing
      | task  | parameters                                | result |
      | Tar   | onlyif, to, user, host, filename, options | error  |
      | Rsync | onlyif, to, user, host, options           | error  |
  
