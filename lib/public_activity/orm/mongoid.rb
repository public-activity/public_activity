require_relative "mongoid/activity.rb"
require_relative "mongoid/adapter.rb"
require_relative "mongoid/activist.rb"
require_relative "mongoid/trackable.rb"

m = PublicActivity::ORM::Mongoid

::PublicActivity.const_set(:Activity, m.const_get(:Activity))
::PublicActivity.const_set(:Adapter, m.const_get(:Adapter))
::PublicActivity.const_set(:Activist, m.const_get(:Activist))
::PublicActivity.const_set(:Trackable, m.const_get(:Trackable))