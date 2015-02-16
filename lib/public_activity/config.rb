module PublicActivity
  # Class used to initialize configuration object.
  class Config
    attr_accessor :enabled, :table_name
    attr_reader :orm

    def initialize
      @enabled    = true
      @table_name = "activities"
      @orm        = :active_record
    end

    def orm=(orm)
      @orm = orm.to_sym
    end
  end
end
