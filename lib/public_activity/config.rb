require 'singleton'

module PublicActivity
  # Class used to initialize configuration object.
  class Config
    attr_accessor :table_name
    attr_reader :orm

    def initialize
      @table_name = "activities"
      @orm        = :active_record
    end

    def orm=(orm)
      @orm = orm.to_sym
    end

    def enabled
      if Thread.current[:public_activity_enabled].nil?
        Thread.current[:public_activity_enabled] = true
      end

      Thread.current[:public_activity_enabled]
    end

    def enabled=(e)
      Thread.current[:public_activity_enabled] = e
    end
  end
end
