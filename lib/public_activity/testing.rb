# frozen_string_literal: true

# This file provides functionality for testing your code with public_activity
# activated or deactivated.
# This file should only be required in test/spec code!
#
# To enable PublicActivity testing capabilities do:
#   require 'public_activity/testing'
module PublicActivity
  # Execute the code block with PublicActiviy active
  #
  # Example usage:
  #   PublicActivity.with_tracking do
  #     # your test code here
  #   end
  def self.with_tracking
    current = PublicActivity.config.enabled
    PublicActivity.config.enabled(true)
    yield
  ensure
    PublicActivity.config.enabled(current)
  end

  # Execute the code block with PublicActiviy deactive
  #
  # Example usage:
  #   PublicActivity.without_tracking do
  #     # your test code here
  #   end
  def self.without_tracking
    current = PublicActivity.enabled?
    PublicActivity.config.enabled(false)
    yield
  ensure
    PublicActivity.config.enabled(current)
  end
end
