# frozen_string_literal: true

module PublicActivity
  unless defined? ::PG::ConnectionBad
    module ::PG
      class ConnectionBad < Exception; end
    end
  end
  unless defined? Mysql2::Error::ConnectionError
    module Mysql2
      module Error
        class ConnectionError < Exception; end
      end
    end
  end

  module ORM
    module ActiveRecord
      # The ActiveRecord model containing
      # details about recorded activity.
      class Activity < ::ActiveRecord::Base
        include Renderable
        self.table_name = PublicActivity.config.table_name
        self.abstract_class = true

        # Define polymorphic association to the parent
        belongs_to :trackable, polymorphic: true

        with_options(optional: true) do
          # Define ownership to a resource responsible for this activity
          belongs_to :owner, polymorphic: true
          # Define ownership to a resource targeted by this activity
          belongs_to :recipient, polymorphic: true
        end

        # Serialize parameters Hash
        begin
          if table_exists?
            unless %i[json jsonb hstore].include?(columns_hash['parameters'].type)
              if ::ActiveRecord.version.release < Gem::Version.new('7.1')
                serialize :parameters, Hash
              else
                serialize :parameters, coder: YAML, type: Hash
              end
            end
          else
            warn("[WARN] table #{name} doesn't exist. Skipping PublicActivity::Activity#parameters's serialization")
          end
        rescue ::ActiveRecord::NoDatabaseError
          warn("[WARN] database doesn't exist. Skipping PublicActivity::Activity#parameters's serialization")
        rescue ::ActiveRecord::ConnectionNotEstablished, ::PG::ConnectionBad, Mysql2::Error::ConnectionError
          warn("[WARN] couldn't connect to database. Skipping PublicActivity::Activity#parameters's serialization")
        end
      end
    end
  end
end
