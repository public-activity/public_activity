require 'active_support'
require 'action_view'
require 'active_record'

# +public_activity+ keeps track of changes made to models
# and allows you to display them to the users.
#
# Check {PublicActivity::Tracked::ClassMethods#tracked} for more details about customizing and specifying
# ownership to users.
module PublicActivity
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload
  autoload :Activist
  autoload :Activity
  autoload :StoreController
  autoload :Tracked
  autoload :Creation
  autoload :Update
  autoload :Destruction
  autoload :VERSION
  autoload :Common

  module Model
    extend ActiveSupport::Concern
    included do
      include Tracked
      include Activist
    end
  end
end

require 'public_activity/view_helpers'
