module PublicActivity
  # Class used to initialize configuration object.
  class Config
    include Singleton
    attr_accessor :enabled

    def initialize
      # Indicates whether PublicActivity is enabled globally
      @enabled         = true
    end
  end
end