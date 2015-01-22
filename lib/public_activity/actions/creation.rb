module PublicActivity
  # Handles creation of Activities upon destruction and update of tracked model.
  module Creation
    extend ActiveSupport::Concern

    included do
      after_create { create_activity :create }
    end
  end
end
