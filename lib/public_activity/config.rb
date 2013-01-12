module PublicActivity
  # Class used to initialize configuration object.
  class Config
    include ::Singleton
    attr_accessor :enabled

    # Static public variable to specify which orm is used
    @@orm = :active_record
    
    ORMMapping = Class.new(Hash) do
      alias_method :register, :[]=
    end.new


    def initialize
      # Indicates whether PublicActivity is enabled globally
      @enabled         = true
      load_orm
    end

    def load_orm
      m = ORMMapping[@@orm].tap {|m| m.touch}
      ::PublicActivity.const_set(:Activity, m.const_get(:Activity))
      ::PublicActivity.const_set(:Adapter, m.const_get(:Adapter))
      ::PublicActivity.const_set(:Activist, m.const_get(:Activist))
      ::PublicActivity.const_set(:Trackable, m.const_get(:Trackable))
    end
  end
end
