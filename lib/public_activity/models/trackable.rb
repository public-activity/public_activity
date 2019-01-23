# frozen_string_literal: true

module PublicActivity
  # Provides association for activities bound to this object by *trackable*.
  module Trackable
    # Delegates to ORM.
    def self.included(base)
      base.extend PublicActivity::inherit_orm("Trackable")
    end
  end
end
