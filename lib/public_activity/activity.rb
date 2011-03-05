require 'active_record'
require 'i18n'
module PublicActivity
  # The ActiveRecord model containing 
  # details about recorded activity.
  class Activity < ActiveRecord::Base
    # Define polymorphic association to the parent
    belongs_to :trackable, :polymorphic => true
    # Define ownership to a user responsible for this activity
    belongs_to :user
    # Serialize parameters Hash
    serialize :parameters, Hash
    
    # Virtual attribute returning already
    # translated key with params
    def text
      params = parameters || {}
      I18n.t(key, params)
    end
  end  
end
