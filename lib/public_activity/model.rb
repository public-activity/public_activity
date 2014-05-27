module PublicActivity
  # Module to be included in ActiveRecord models. Adds required functionality.
  module Model
    extend ActiveSupport::Concern
    included do
      include Common
      include Deactivatable
      include Tracked
      include Activist  # optional associations by recipient|owner
    end
  end
end
