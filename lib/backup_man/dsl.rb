module BackupMan
  
  # use "self.extend DSL" to use this module
  module DSL

    def def_dsl( name, var = name )
      class_eval( %Q{
        def #{name}( #{var} )
          @#{var} = #{var}
        end
      })
    end    

  end #DSL

end #BackupMan
