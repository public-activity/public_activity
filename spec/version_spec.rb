require 'spec_helper'

describe PublicActivity, 'VERSION' do
  it 'is present' do
    PublicActivity::VERSION.should_not be_nil
  end
    
  it 'is frozen' do
    PublicActivity::VERSION.frozen?.should be(true)
  end
end
