require 'active_record'
require 'i18n'
module KeepTrack
  class Activity < ActiveRecord::Base
    belongs_to :trackable, :polymorphic => true
    belongs_to :user
    serialize :parameters, Hash
    
    # Virtual attribute returning already
    # translated key with params
    def text
      params = parameters || {}
      I18n.t(key, params)
    end
  end  
end
