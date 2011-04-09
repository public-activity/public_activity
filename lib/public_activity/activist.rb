module PublicActivity
  # Module extending classes that serve as owners
  module Activist
    extend ActiveSupport::Concern
    # Module extending classes that serve as owners
    module ClassMethods
      # Adds has_many :activities association to model
      # so you can list activities performed by the owner.
      # It is completely optional, but simplifies your work.
      # 
      # == Usage:
      # In model:
      #
      #   class User < ActiveRecord::Base
      #     activist
      #   end 
      #
      # In controller:
      #   User.first.activities
      #
      def activist
        has_many :activities, :class_name => "PublicActivity::Activity", :as => :owner
      end    
    end
  end
end
