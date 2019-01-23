# frozen_string_literal: true

module PublicActivity
  # Handles creation of Activities upon destruction of tracked model.
  module Destruction
    extend ActiveSupport::Concern

    included do
      before_destroy :activity_on_destroy
    end

    private

    # Records an activity upon destruction of the tracked model
    def activity_on_destroy
      create_activity(:destroy)
    end
  end
end
