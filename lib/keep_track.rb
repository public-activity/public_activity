require 'rails'
require 'active_support/dependencies'
require 'active_record'

module KeepTrack
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload
  autoload :Activity
  autoload :Tracked
  autoload :Creation
  autoload :VERSION
  
  included do
    include Tracked
  end  
  
  module ClassMethods
    def tracked(*args)
      return if tracked?
      options = args.extract_options!
      puts options.inspect
      has_many :activities, :class_name => "KeepTrack::Activity", :as => :trackable
      
      include Creation
      
    end
  end

end

ActiveRecord::Base.send :include, KeepTrack
