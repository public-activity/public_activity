require 'test_helper'

describe PublicActivity do

  describe ".configure" do
    it "allows configuring ORM" do
      PublicActivity.configure do |config|
        config.orm = ENV['PA_ORM']
      end
      PublicActivity.config.orm.must_equal ENV['PA_ORM'].to_sym
    end

    it "allows configuring table_name for AR model" do
      PublicActivity.configure do |config|
        config.table_name = "zomg_activitos"
      end
      PublicActivity.config.table_name.must_equal "zomg_activitos"

      PublicActivity.configure do |config|
        config.table_name = "activities"
      end
    end
  end
end
