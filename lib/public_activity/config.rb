require 'singleton'

module PublicActivity
  # Class used to initialize configuration object.
  class Config
    include ::Singleton
    attr_accessor :enabled, :table_name

    # Evaluates given block to provide DSL configuration.
    # @example Initializer for Rails
    #   PublicActivity::Config.set do
    #     orm :mongo_mapper
    #     enabled false
    #     table_name "activities"
    #   end
    def self.set &block
      b = Block.new
      b.instance_eval &block
      orm(b.orm) unless b.orm.nil?
      instance
      Thread.current[:public_activity_enabled] = b.enabled unless b.enabled.nil?
      Thread.current[:public_activity_table_name] = b.table_name unless b.enabled.nil?
    end

    # Set the ORM for use by PublicActivity.
    def self.orm(orm = nil)
      Thread.current[:public_activity_orm] = (orm ? orm.to_sym : false) || Thread.current[:public_activity_orm]
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

    def table_name
      Thread.current[:public_activity_orm] || "activities"
    end

    # Provides simple DSL for the config block.
    class Block
      attr_reader :orm, :enabled, :table_name
      # @see Config#orm
      def orm(orm = nil)
        @orm = (orm ? orm.to_sym : false) || @orm
      end

      # Decides whether to enable PublicActivity.
      # @param en [Boolean] Enabled?
      def enabled(en = nil)
        @enabled = (en.nil? ? @enabled : en)
      end

      # Sets the table_name
      # for the model
      def table_name(name = nil)
        @table_name = (name.nil? ? @table_name : name)
      end
    end
  end
end
