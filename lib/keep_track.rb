require 'rails'
require 'active_support/dependencies'

module KeepTrack
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload
  autoload :Activity
end

require 'keep_track/models'
ActiveRecord::Base.send :include, KeepTrack::Models
