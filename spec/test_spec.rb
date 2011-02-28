require 'spec_helper'

describe 'Numbers' do
  context 'comparing one to one(float)' do
    it 'should pass with equal matcher' do
      1.should eq(1.0)
    end
    
    it 'should fail with "be" matcher' do
      1.should_not be(1.0)
    end
  end
end
