require 'test_helper'

class TestConfig < Minitest::Unit
  def test_configuring_orm
    PublicActivity.configure do |config|
      config.orm = ENV["PA_ORM"]
    end

    assert_equal ENV["PA_ORM"].to_sym, PublicActivity.config.orm
  end

  def test_configuring_table_name
    PublicActivity.configure do |config|
      config.table_name = "zomg_activitos"
    end

    assert_equal "zomg_activitos", PublicActivity.config.table_name

    PublicActivity.configure do |config|
      config.table_name = "activities"
    end
  end
end
