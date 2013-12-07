module PublicActivity
  # Handles creation of Activities upon destruction of tracked model.
  module Destruction
    extend ActiveSupport::Concern

    included do
      before_destroy { create_activity :destroy }
    end
  end
end
