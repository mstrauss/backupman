module BackupMan

  # use "include DSL" to use this module
  module DSL

    # extend host class with class methods when we're included
    def self.included(host_class)
      host_class.extend(ClassMethods)
    end
    
    def debug_log_dsl_info
      Log.instance.debug( "Job settings:")
      self.class.dsl_methods.each do |method, var|
        Log.instance.debug( "  #{method} = #{self.instance_variable_get("@#{var}")}" )
      end
    end
    
    module ClassMethods
                  
      def def_dsl( name, var = name )
        class_eval( %Q{
          def #{name}( #{var} )
            @#{var} = #{var}
          end
          })
        register_dsl( name, var )
      end

      def register_dsl( name, var )
        @dsl_methods = [] if @dsl_methods.nil?
        @dsl_methods << [name, var]
        puts "#{self} #{self.dsl_methods.join ","}"
      end
      
      # returns an array of all dsl methods of this and all superclasses
      def dsl_methods
        dsl_methods = []
        if self.superclass != Object
          dsl_methods = dsl_methods | self.superclass.dsl_methods
        end
        dsl_methods | @dsl_methods
      end


    end # ClassMethods
  end #DSL
end #BackupMan
