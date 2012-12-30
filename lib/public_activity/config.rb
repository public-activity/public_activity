module PublicActivity
  # Class used to initialize configuration object.
  class Config
    include Singleton
    attr_accessor :enabled
    attr_reader   :orm

    def initialize
      # Indicates whether PublicActivity is enabled globally
      @enabled         = true
      @orm             = :active_record
    end

    def orm=(orm)
      @orm = orm.to_sym
      load_orm
    end

    def load_orm
      require 'active_record' if @orm == :active_record
      require_relative "orm/#{@orm}"
    end
  end
end
