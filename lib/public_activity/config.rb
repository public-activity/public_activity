module PublicActivity
  # Class used to initialize configuration object.
  class Config
    attr_accessor :enabled, :table_name, :model_name
    attr_reader :orm

    def initialize
      @enabled    = true
      @table_name = "activities"
      @model_name = "::PublicActivity::Activity"
      @orm        = :active_record
    end

    def orm=(orm)
      @orm = orm.to_sym
    end
  end
end
