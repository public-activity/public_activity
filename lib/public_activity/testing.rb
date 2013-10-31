require 'public_activity'

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
  #   PublicActivity.with_log do
  #     # your test code here
  #   end
  def self.with_log
    current = PublicActivity.enabled
    PublicActivity.enabled = true
    yield
  ensure
    PublicActivity.enabled = current
  end

  # Execute the code block with PublicActiviy deactive
  # 
  # Example usage:
  #   PublicActivity.without_log do
  #     # your test code here
  #   end
  def self.without_log
    current = PublicActivity.enabled
    PublicActivity.enabled = false
    yield
  ensure
    PublicActivity.enabled = current
  end
end
