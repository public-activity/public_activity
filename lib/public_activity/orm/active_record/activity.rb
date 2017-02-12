module PublicActivity
  module ORM
    module ActiveRecord
      # The ActiveRecord model containing
      # details about recorded activity.
      class Activity < ::ActiveRecord::Base
        include Renderable
        self.table_name = PublicActivity.config.table_name

        # Define polymorphic association to the parent
        belongs_to :trackable, :polymorphic => true

        case ::ActiveRecord::VERSION::MAJOR
        when 3..4
          # Define ownership to a resource responsible for this activity
          belongs_to :owner, :polymorphic => true
          # Define ownership to a resource targeted by this activity
          belongs_to :recipient, :polymorphic => true
        when 5
          with_options(:required => false) do
            # Define ownership to a resource responsible for this activity
            belongs_to :owner, :polymorphic => true
            # Define ownership to a resource targeted by this activity
            belongs_to :recipient, :polymorphic => true
          end
        end

        # Serialize parameters Hash
        serialize :parameters, Hash unless [:json, :jsonb, :hstore].include?(columns_hash['parameters'].type)

        if ::ActiveRecord::VERSION::MAJOR < 4 || defined?(ProtectedAttributes)
          attr_accessible :key, :owner, :parameters, :recipient, :trackable
        end
      end
    end
  end
end
