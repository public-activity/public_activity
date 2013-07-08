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

    # Evaluates given block to provide DSL configuration.
    # @example Initializer for Rails
    #   PublicActivity::Config.set do
    #     orm :mongo_mapper
    #     enabled false
    #   end
    def self.set &block
      b = Block.new
      b.instance_eval &block
      orm = b.instance_variable_get(:@orm)
      @@orm = orm unless orm.nil?
      enabled = b.instance_variable_get(:@en)
      instance
      instance.instance_variable_set(:@enabled, enabled) unless enabled.nil?
    end

    # Set the ORM for use by PublicActivity.
    def self.orm(orm = nil)
      @@orm = (orm ? orm.to_sym : false) || @@orm
    end

    # alias for {#orm}
    # @see #orm
    def self.orm=(orm = nil)
      orm(orm)
    end

    # instance version of {Config#orm}
    # @see Config#orm
    def orm(orm=nil)
      self.class.orm(orm)
    end

    # Provides simple DSL for the config block.
    class Block
      # @see Config#orm
      def orm(orm = nil)
        @orm = (orm ? orm.to_sym : false) || @orm
      end

      # Decides whether to enable PublicActivity.
      # @param en [Boolean] Enabled?
      def enabled(en = nil)
        @en = (en.nil? ? @en : en)
      end
    end
  end
end
