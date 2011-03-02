require 'active_record'
require 'i18n'
module KeepTrack
  class Activity < ActiveRecord::Base
    belongs_to :trackable, :polymorphic => true
    belongs_to :user
    serialize :parameters, Hash
    
    def text
      params = parameters || {}
      params.merge!({:user => user.email})
      I18n.t(key, params)
    end
  end  
end
