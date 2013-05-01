module PublicActivity
  module Trackable
    def self.included(base)
      base.extend PublicActivity::inherit_orm("Trackable")
    end
  end
end