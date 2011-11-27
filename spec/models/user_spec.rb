require File.expand_path('../../spec_helper', __FILE__)
load "users_with_karma.rb"

describe User do
  fixtures :users
  
  before :each do
    @user = User.find 1
    @another_user = User.find 2
    @bad_user = User.find 3
    @user4 = User.find 4
  end

  describe "#votes" do
    it "should be present" do
      @user.should respond_to(:votes)
    end
  end
  
  describe "#karma" do
    it "should have a karma" do
      @user.should respond_to(:karma)
    end
  end
  
  describe "karma scope" do
    # Test if there is no any anon records in karma-scoped queries.
    def no_anon(records)
      [-10, 20].each do |karma_val|
        AnonymousUser.create!()
        AnonymousUser.first.update_attribute(:karma, karma_val)
        return false if records.call.map(&:login).include? ""
        AnonymousUser.first.delete
      end
      
      true
    end
  
    describe "for good users" do
      it "should be constructed of users with karma >= 0 and ordered by it (max first)" do
        User.good.should == [@user, @another_user, @user4] 
      end
      
      it "shouldn't contain any anon" do
        no_anon(lambda { User.good }).should be_true
      end
    end
    
    describe "for bad users" do
      it "should be constructed of users with karma < 0 and ordered by it (max first)" do
        User.bad.should == [@bad_user]
      end
      
      it "shouldn't contain any anon" do
        no_anon(lambda { User.bad }).should be_true
      end
    end
  end
  
  def another_user_karma
    lambda { @another_user.reload; @another_user.karma }
  end
  
  describe "voting" do
    describe "#vote_for" do
      it "increases karma for specified user" do
        lambda { @user.vote_for(@another_user) }.should change { another_user_karma.call }.by(1)
      end
      
      it "cannot vote for self" do
        @user.vote_for @user
        @user.should have(1).errors
      end
      
      it "doesn't change own karma" do
        lambda { @user.vote_for(@user) }.should_not change { another_user_karma.call }
      end
      
      it "changes votes entry for this user" do
        Vote.should_receive(:change).with(@user, @another_user, 1)
        @user.vote_for(@another_user)
      end
    end
    
    describe "#vote_against" do
      it "decreases karma for specified user" do
        lambda { @user.vote_against(@another_user) }.should change { another_user_karma.call }.by(-1)
      end
      
      it "cannot vote against self" do
        @user.vote_against @user
        @user.should have(1).errors
      end
      
      it "doesn't change own karma" do
        lambda { @user.vote_against(@user) }.should_not change { another_user_karma.call }
      end
      
      it "changes votes entry for this user" do
        Vote.should_receive(:change).with(@user, @another_user, -1)
        @user.vote_against(@another_user)
      end
    end
  end
  
  describe "destroy" do
    it "should delete all Vote records by this user" do
      Vote.should_receive(:take_back_all_from).with(@user)
      @user.destroy           
    end   
    
    it "should take all votes back" do
      lambda { @user.destroy }.should change { another_user_karma.call }.from(5).to(0)  
    end
  end 
end
