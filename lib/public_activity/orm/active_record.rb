module PublicActivity
  module ORM
    # TODO: Docs
    module ActiveRecord
      def self.touch
        require_relative 'active_record/activity.rb'
        require_relative 'active_record/adapter.rb'
        require_relative 'active_record/activist.rb'
        require_relative 'active_record/trackable.rb'
      end
    end
  end

  Config::ORMMapping.register(:active_record, ORM::ActiveRecord)
end
