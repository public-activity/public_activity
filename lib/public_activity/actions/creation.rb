# frozen_string_literal: true

module PublicActivity
  # Handles creation of Activities upon destruction and update of tracked model.
  module Creation
    extend ActiveSupport::Concern

    included do
      after_create :activity_on_create
    end

    private

    # Creates activity upon creation of the tracked model
    def activity_on_create
      create_activity(:create)
    end
  end
end
