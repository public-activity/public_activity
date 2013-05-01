require 'singleton'

module PublicActivity
  # Class used to initialize configuration object.
  class Config
    include ::Singleton
    attr_accessor :enabled

    @@orm = :active_record

    def initialize
      # Indicates whether PublicActivity is enabled globally
      @enabled  = true
    end

    def self.set &block
      b = Block.new
      b.instance_eval &block
      orm = b.instance_variable_get(:@orm)
      @@orm = orm unless orm.nil?
      enabled = b.instance_variable_get(:@en)
      instance
      instance.instance_variable_set(:@enabled, enabled) unless enabled.nil?
    end

    def self.orm(orm = nil)
      @@orm = (orm ? orm.to_sym : false) || @@orm
    end

    def self.orm=(orm = nil)
      orm(orm)
    end

    def orm(orm=nil)
      self.class.orm(orm)
    end

    class Block
      def orm(orm = nil)
        @orm = (orm ? orm.to_sym : false) || @orm
      end

      def enabled(en = nil)
        @en = (en.nil? ? @en : en)
      end
    end
  end
end
