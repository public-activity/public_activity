require 'test_helper'

describe PublicActivity::Common do
  before do
    @owner     = User.create(:name => "Peter Pan")
    @recipient = User.create(:name => "Bruce Wayne")
    @options   = {:params => {:author_name => "Peter",
                  :summary => "Default summary goes here..."},
                  :owner => @owner}
  end
  subject { article(@options).new }

  it 'uses global fields' do
    subject.save
    activity = subject.activities.last
    activity.parameters.must_equal @options[:params]
    activity.owner.must_equal @owner
  end

  it 'inherits instance parameters' do
    subject.activity :params => {:author_name => "Michael"}
    subject.save
    activity = subject.activities.last

    activity.parameters[:author_name].must_equal "Michael"
  end

  it 'accepts instance recipient' do
    subject.activity :recipient => @recipient
    subject.save
    subject.activities.last.recipient.must_equal @recipient
  end

  it 'accepts instance owner' do
    subject.activity :owner => @owner
    subject.save
    subject.activities.last.owner.must_equal @owner
  end

  it 'accepts owner as a symbol' do
    klass = article(:owner => :user)
    @article = klass.new(:user => @owner)
    @article.save
    activity = @article.activities.last

    activity.owner.must_equal @owner
  end

end