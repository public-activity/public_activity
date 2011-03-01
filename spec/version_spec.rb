require 'spec_helper'

describe KeepTrack, 'VERSION' do
  it 'is present' do
    KeepTrack::VERSION.should_not be_nil
  end
    
  it 'is frozen' do
    KeepTrack::VERSION.frozen?.should be(true)
  end
end
