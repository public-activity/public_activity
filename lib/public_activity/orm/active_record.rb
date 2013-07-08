require 'active_record'
# Support for ActiveRecord for PublicActivity. Used by default and supported
# officialy.
module PublicActivity::ORM::ActiveRecord; end
require_relative 'active_record/activity.rb'
require_relative 'active_record/adapter.rb'
require_relative 'active_record/activist.rb'
require_relative 'active_record/trackable.rb'