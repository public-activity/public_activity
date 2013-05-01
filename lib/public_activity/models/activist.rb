module PublicActivity
  module Activist
    def self.included(base)
      base.extend PublicActivity::inherit_orm("Activist")
    end
  end
end