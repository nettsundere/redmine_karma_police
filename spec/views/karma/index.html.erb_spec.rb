require File.expand_path('../../../spec_helper', __FILE__)

describe "karma/index.html.erb" do
  before :each do
    @user = mock_model User
    User.stub!(:current).and_return @user
    @user.stub!(:name).and_return "some"
    @user.stub!(:admin?).and_return false
    @user.stub!(:login).and_return "some_login"
    template.stub!(:karma_block_for).and_return "ok"
    
    assigns[:group] = @user
    assigns[:good] = [@user]
    assigns[:bad] = [@user]
  end

  it "should include karma.css stylesheet" do
    template.should_receive(:stylesheet_link_tag).once.with("karma.css", :plugin => :redmine_karma_police)
    render
  end
  
  it "should create karma-related block for each user" do
    template.should_receive(:karma_block_for).exactly(2).times
    render
  end
end
