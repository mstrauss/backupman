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
    
    def debug_log_dsl_info
      Log.debug( "Job settings:")
      self.class.dsl_methods.each do |method, var|
        Log.debug( "  #{method} = #{self.instance_variable_get("@#{var}")}" )
      end
    end
    
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
