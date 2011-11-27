require File.expand_path('../../spec_helper', __FILE__)

describe Vote do
  fixtures :votes, :users

  before :all do
    @vote = Vote.find 1 
    
    # Changes of karma for this users is in database.
    @user1 = User.find 1
    @user2 = User.find 2
    
    # Changes of karma for this users isn't stored yet.
    @user3 = User.find 3
    @user4 = User.find 4
  end

  it "#user should be present" do
    @vote.should respond_to(:user)
  end
  
  it "#affected user should be present" do
    @vote.should respond_to(:affected)
  end
  
  # Get stored karma change value made by user for the affected user or nil
  # if user never changed affected user's karma value.
  def stored_for(user, affected_user)
    v = Vote.find_by_user_id_and_affected_id(user.id, affected_user.id)
    v && v.value
  end
  
  describe "#change" do
    it "changes stored value by the required value" do
      lambda { Vote.change(@user1, @user2, 100) }.should change { stored_for(@user1, @user2) }.from(5).to(105)
    end
    
    it "initializes value by the required value if value not stored" do
      lambda { Vote.change(@user3, @user4, 100) }.should change { stored_for(@user3, @user4) }.from(nil).to(100)
    end
  end
  
  describe "#take_back_all_from" do
    it "should remove all votes stored for user" do
      lambda { Vote.take_back_all_from(@user1) }.should change { stored_for(@user1, @user2) }.from(5).to(nil)
    end
  end
end
