# frozen_string_literal: true

require 'singleton'

module PublicActivity
  # Class used to initialize configuration object.
  class Config
    include ::Singleton

    # Evaluates given block to provide DSL configuration.
    # @example Initializer for Rails
    #   PublicActivity::Config.set do
    #     orm :mongo_mapper
    #     enabled false
    #     table_name "activities"
    #   end
    def self.set &block
      b = Block.new
      b.instance_eval(&block)
      instance
      orm(b.orm) unless b.orm.nil?
      enabled(b.enabled) unless b.enabled.nil?
      table_name(b.table_name) unless b.table_name.nil?
    end

    # alias for {#orm}
    # @see #orm
    def self.orm=(orm = nil)
      orm(orm)
    end

    # alias for {#enabled}
    # @see #enabled
    def self.enabled=(en = nil)
      enabled(en)
    end

    # instance version of {Config#orm}
    # @see Config#orm
    def orm(orm=nil)
      self.class.orm(orm)
    end

    # instance version of {Config#table_name}
    # @see Config#orm
    def table_name(name = nil)
      self.class.table_name(name)
    end

    # instance version of {Config#enabled}
    # @see Config#orm
    def enabled(en = nil)
      self.class.enabled(en)
    end

    # Set the ORM for use by PublicActivity.
    def self.orm(orm = nil)
      if orm.nil?
        Thread.current[:public_activity_orm] || :active_record
      else
        Thread.current[:public_activity_orm] = orm.to_sym
      end
    end

    def self.table_name(name = nil)
      if name.nil?
        Thread.current[:public_activity_table_name] || "activities"
      else
        Thread.current[:public_activity_table_name] = name
      end
    end

    def self.enabled(en = nil)
      if en.nil?
        value = Thread.current[:public_activity_enabled]
        value.nil? ? true : value
      else
        Thread.current[:public_activity_enabled] = en
      end
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
