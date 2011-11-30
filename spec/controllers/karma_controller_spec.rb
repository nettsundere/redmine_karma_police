require File.expand_path('../../spec_helper', __FILE__)

describe KarmaController do
  describe "when user isn't logged" do
    before :each do
      @user = mock_model User
      User.stub!(:current).and_return @user
      @user.stub!(:logged?).and_return false
    end
    
    it "#index should be redirected to login page" do
      get :index
      response.should redirect_to :controller => :login, :back_url => controller.request.url
    end
    
    it "#vote should be redirected to login page" do
      put :vote, :id => 666, :direction => :for
      response.should redirect_to :controller => :login, :back_url => controller.request.url
    end
  end

  describe "when logged english user" do
    before :each do
      @user = mock_model User
      User.stub!(:current).and_return @user
      @user.stub!(:logged?).and_return true
      @user.stub!(:language).and_return :en
      @user.stub!(:id).and_return 100
    end
    
    describe "can view karma" do 
      before :each do
        @user.stub!(:karma_viewer).and_return true
      end
      
      it "he can see top of good users in index" do
       User.should_receive(:good).once
       get :index
      end
      
      it "he can see top of bad users in index" do
        User.should_receive(:bad).once
        get :index
      end
      
      it "should be success when requested index" do
        get :index
        response.should be_success
      end
    end
    
    describe "can change karma" do
      before :each do
        @user.stub!(:karma_editor).and_return true
        some_user = mock_model(User)
        some_user.stub!(:name).and_return "test_name"
        User.stub(:find_by_id).and_return some_user 
        
        some_error = Class.new
        some_error.stub!(:on_base).and_return "test"
        @user.stub!(:errors).and_return some_error
      end
      
      it "when voting for succeeded, then 0 errors should be present" do
        @user.stub!(:vote_for).and_return true
        put :vote, :id => 666, :direction => "for"
        flash[:error].should be_nil
        response.should redirect_to :action => :index
      end
      
      it "when voting for failed, then error should be present" do
        @user.stub!(:vote_for).and_return false
        put :vote, :id => 666, :direction => "for"
        flash[:error].should_not be_empty
        response.should redirect_to :action => :index
      end
      
      it "when voting against succeeded, then 0 errors should be present" do
        @user.stub!(:vote_against).and_return true
        put :vote, :id => 666, :direction => "against"
        flash[:error].should be_nil
        response.should redirect_to :action => :index
      end
      
      it "when voting against failed, then error should be present" do
        @user.stub!(:vote_against).and_return false
        put :vote, :id => 666, :direction => "against"
        flash[:error].should_not be_empty
        response.should redirect_to :action => :index
      end
    end
    
    describe "can't change karma, but can view karma" do
      before :each do
        @user.stub!(:karma_editor).and_return false
        @user.stub!(:karma_viewer).and_return true
      end
      
      it "should render #index without problems" do
        get :index
        response.should_not be_redirect
      end
    end
    
    describe "can change karma, but can't view karma" do
      before :each do
        @user.stub!(:karma_editor).and_return true
        @user.stub!(:karma_viewer).and_return false
      end
      
      it "should render #index without problems" do
        get :index
        response.should_not be_redirect
      end
      
      it "should receive message about disabled ability to view karma" do
        get :index
        flash.now[:message].should_not be_empty
      end
    end
    
    describe "cannot change or view karma" do
      before :each do
        @user.stub!(:karma_editor).and_return false
        @user.stub!(:karma_viewer).and_return false
      end
      
      it "should be redirected" do
        get :index
        response.should redirect_to root_path
      end
      
      it "shouldn't have any errors" do
        get :index
        flash[:error].should be_nil
      end
    end
  end
end
