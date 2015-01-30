require 'singleton'
require 'active_support/configurable'

module PublicActivity
  # Class used to initialize configuration object.
  class Config
    include ActiveSupport::Configurable

    config_accessor :enabled do true end
    config_accessor :table_name do 'activities' end
    config_accessor :orm do :active_record end

  end

end
