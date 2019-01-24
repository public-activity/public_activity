# frozen_string_literal: true

module PublicActivity
  # Handles creation of Activities upon destruction and update of tracked model.
  module Update
    extend ActiveSupport::Concern

    included do
      after_update :activity_on_update
    end

    private

    # Creates activity upon modification of the tracked model
    def activity_on_update
      # Either use #changed? method for Rails < 5.1 or #saved_changes? for recent versions
      create_activity(:update) if respond_to?(:saved_changes?) ? saved_changes? : changed?
    end
  end
end
