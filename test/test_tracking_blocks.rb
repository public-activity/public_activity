require 'test_helper'

class TestTrackingBlocks < Minitest::Unit::TestCase
  def test_tracking_block
    PublicActivity.enabled = false

    PublicActivity.with_tracking do
      assert PublicActivity.enabled?
    end
  end

  def test_tracking_restoring
    PublicActivity.enabled = false
    PublicActivity.with_tracking do
      # something
    end
    refute PublicActivity.enabled?
  end

  def test_without_tracking
    PublicActivity.enabled = true

    PublicActivity.without_tracking do
      refute PublicActivity.enabled?
    end
  end

  def test_without_tracking_restoring
    PublicActivity.enabled = true

    PublicActivity.without_tracking {}

    assert PublicActivity.enabled?
  end
end
