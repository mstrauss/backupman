class Array
  # @return [Array] a deep copy of self
  def dclone
    Marshal.load( Marshal.dump( self ) )
  end
end


module BackupMan

  # use "include DSL" to use this module
  module DSL
    
    # extend host class with class methods when we're included
    def self.included(host_class)
      host_class.extend(ClassMethods)
    end
    
    # yields the block which comes from the DSL configuration file; also
    # registers the new backup configuration with {BackupMan}
    def initialize( name )
      @name = name      
      yield(self) if block_given?
      BackupMan.instance.register_backup( self )
    end
    
    def debug_log_dsl_info
      Log.debug( "Job settings:")
      self.class.dsl_methods.each do |method, var|
        Log.debug( "  #{method} = #{self.instance_variable_get("@#{var}")}" )
      end
    end
    
    # calling this actually runs the backup/task; DO NOT override this; override
    # _run instead
    def run
      log_begin_of_run
      set_defaults
      debug_log_dsl_info
      unless missing_required_parameters.empty?
        Log.error( "#{self}: A required parameter is missing: #{missing_required_parameters.join ' '}")
        return
      end
      onlyif = eval( @onlyif )
      Log.debug( "onlyif = { #{@onlyif} } evaluates #{onlyif}" )
      if onlyif
        _run
      else
        Log.info( "#{self}: Preconditions for backup run not fulfilled.")
      end
      log_end_of_run
    end

    # @return [String]
    def to_s
      "#{self.class} #{self.name}"
    end


    # @abstract override this to implement the actual backup commands
    def _run
      throw "Hey. Cannot run just 'Backup'."
    end
    private :_run

    # @return [Array of Strings] of missing parameters
    def missing_required_parameters
      missing = []
      self.class.dsl_methods.each do |name, var, mandatory|      
        missing << name if mandatory && self.instance_variable_get("@#{var}").empty?
      end
      missing
    end
    private :missing_required_parameters

    # not used acutally
    def log_begin_of_run
      Log.info( "Starting #{self.class} run for #{@name}." )
    end
    private :log_begin_of_run

    # simply logs that the program terminates
    def log_end_of_run
      Log.info( "Finished #{self.class} run for #{@name}." )
    end
    private :log_end_of_run


    module ClassMethods
      
      # @param [String] name
      # @param [String] variable name, used for internal storage
      # @param [Boolean] mandatory, true if this var is a required parameter
      def def_dsl( name, var = name, mandatory = false )
        class_eval( %Q{
          def #{name}( #{var} )
            @#{var} = #{var}
          end
          })
        register_dsl( name, var, mandatory )
      end
      
      # @param [Symbol] name of required parameter
      def def_dsl_required( required_name )
        self.dsl_methods.each_index do |i|
          if self.dsl_methods[i][0] == required_name
            self.dsl_methods[i][2] = true
          end
        end
      end

      def register_dsl( name, var, mandatory )
        @dsl_methods = [] if @dsl_methods.nil?
        @dsl_methods << [name, var, mandatory]
      end
      
      # returns an array of all dsl methods of this and all superclasses
      def dsl_methods
        # if we dont have anything yet, we copy from superclass (copying is
        # necessary beacause we might change the :required setting)
        @dsl_methods ||= self.superclass.dsl_methods.dclone
        @dsl_methods
      end

    end # ClassMethods
      
  end #DSL
end #BackupMan
