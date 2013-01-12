require 'singleton'

module PublicActivity
  # Class used to initialize configuration object.
  class Config
    include ::Singleton
    attr_accessor :enabled
    cattr_reader  :orm

    @@orm = :active_record

    def initialize
      # Indicates whether PublicActivity is enabled globally
      @enabled  = true
      load_orm
    end

    def self.orm=(orm)
      @@orm = orm.to_sym
    end

    def load_orm
      require "public_activity/orm/#{@@orm.to_s}"
      m = "PublicActivity::ORM::#{@@orm.to_s.classify}".constantize
      ::PublicActivity.const_set(:Activity,  m.const_get(:Activity))
      ::PublicActivity.const_set(:Adapter,   m.const_get(:Adapter))
      ::PublicActivity.const_set(:Activist,  m.const_get(:Activist))
      ::PublicActivity.const_set(:Trackable, m.const_get(:Trackable))
    end
  end
end
