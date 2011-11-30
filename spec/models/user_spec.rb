require File.expand_path('../../spec_helper', __FILE__)
load "redmine_karma_police/users_with_karma.rb"

describe User do
  fixtures :users
  
  before :each do
    @user = User.find 1
    @another_user = User.find 2
    @bad_user = User.find 3
    @user4 = User.find 4
  end

  describe "#karma_votes" do
    it "should be present" do
      @user.should respond_to(:karma_votes)
    end
  end
  
  describe "#karma" do
    it "should have a karma" do
      @user.should respond_to(:karma)
    end
  end
  
  describe "karma settings" do
    it "#karma_editor should be present" do
      @user.should respond_to(:karma_editor)
    end
    
    it "#karma_viewer should be present" do
      @user.should respond_to(:karma_viewer)
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
      describe "when user isn't a karma_editor" do
        before :each do
          @user.stub!(:karma_editor).and_return false
        end
      
        it "cannot vote for" do
          @user.vote_for @another_user
          @user.should have(1).errors
        end
        
        it "doesn't change karma of another_user" do
          lambda { @user.vote_for(@another_user) }.should_not change { another_user_karma.call }
        end
      end
    
      it "increases karma for specified user" do
        lambda { @user.vote_for(@another_user) }.should change { another_user_karma.call }.by(1)
      end
      
      it "cannot vote for self" do
        @user.vote_for @user
        @user.should have(1).errors
      end
      
      it "cannot vote for User which doesn't exists" do
        @user.vote_for User.find_by_id(100500)
        @user.should have(1).errors
      end
      
      it "doesn't change own karma" do
        lambda { @user.vote_for(@user) }.should_not change { another_user_karma.call }
      end
      
      it "changes votes entry for this user" do
        KarmaVote.should_receive(:change).with(@user, @another_user, 1)
        @user.vote_for(@another_user)
      end
    end
    
    describe "#vote_against" do
      describe "when user isn't a karma_editor" do
        before :each do
          @user.stub!(:karma_editor).and_return false
        end
      
        it "cannot vote against" do
          @user.vote_against @another_user
          @user.should have(1).errors
        end
        
        it "doesn't change karma of another_user" do
          lambda { @user.vote_against(@another_user) }.should_not change { another_user_karma.call }
        end
      end
    
      it "decreases karma for specified user" do
        lambda { @user.vote_against(@another_user) }.should change { another_user_karma.call }.by(-1)
      end
      
      it "cannot vote against self" do
        @user.vote_against @user
        @user.should have(1).errors
      end
      
      it "cannot vote against User which doesn't exists" do
        @user.vote_against User.find_by_id(100500)
        @user.should have(1).errors
      end
      
      it "doesn't change own karma" do
        lambda { @user.vote_against(@user) }.should_not change { another_user_karma.call }
      end
      
      it "changes votes entry for this user" do
        KarmaVote.should_receive(:change).with(@user, @another_user, -1)
        @user.vote_against(@another_user)
      end
    end
  end
  
  describe "destroy" do
    it "should delete all Vote records by this user" do
      KarmaVote.should_receive(:take_back_all_from).with(@user)
      @user.destroy           
    end   
    
    it "should take all votes back" do
      lambda { @user.destroy }.should change { another_user_karma.call }.from(5).to(0)  
    end
  end
  
  describe "ability to change karma options" do
    before :each do
      @current_user = mock_model User 
      @current_user .stub!(:logged?).and_return true
      @current_user .stub!(:language).and_return :en
      User.stub!(:current).and_return @current_user 
      
      @user = User.find 1
    end
    
    describe "when user is admin" do
      before :each do
        @current_user.stub!(:admin?).and_return true
      end
      
      it "#karma_editor should be in safe_attributes" do
        @user.safe_attribute_names.should include("karma_editor")
      end
      
      it "#karma_viewer should be in safe_attributes" do
        @user.safe_attribute_names.should include("karma_viewer")
      end 
    end
    
    describe "when user isn't admin" do
      before :each do
        @current_user.stub!(:admin?).and_return false
      end
      
      it "#karma_editor shouldn't be in safe_attribute_names" do
        @user.safe_attribute_names.should_not include("karma_editor")
      end
      
      it "#karma_viewer shouldn't be in safe_attributes" do
        @user.safe_attribute_names.should_not include("karma_viewer")
      end
    end
  end
end
