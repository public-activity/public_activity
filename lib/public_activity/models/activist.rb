# frozen_string_literal: true

module PublicActivity
  # Provides helper methods for selecting activities from a user.
  module Activist
    # Delegates to configured ORM.
    def self.included(base)
      base.extend PublicActivity::inherit_orm("Activist")
    end
  end
end
