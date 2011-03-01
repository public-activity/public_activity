require 'active_record'

module KeepTrack
  class Activity < ActiveRecord::Base
    belongs_to :trackable, :polymorphic => true
    belongs_to :user
    serialize :parameters, Hash
    
    def text
      translate(key, parameters || {})
    end
  end  
end
