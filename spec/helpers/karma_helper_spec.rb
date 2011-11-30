require File.expand_path('../../spec_helper', __FILE__)

describe KarmaHelper do
  describe "#karma_block_for" do
    before :each do
      @current_user = mock_model User
      User.stub!(:current).and_return @current_user
      @user_for = mock_model User
    end
  
    describe "when user can view karma" do
      before :each do
        @current_user.stub!(:karma_viewer).and_return true
        @current_user.stub!(:karma_editor).and_return false
      end
    
      it "should use user's karma value" do
        @user_for.should_receive(:karma).once
        helper.karma_block_for @user_for
      end
    end
    
    describe "when user can't view karma" do
      before :each do
        @current_user.stub!(:karma_viewer).and_return false
        @current_user.stub!(:karma_editor).and_return false
      end
    
      it "shouldn't use user's karma value" do
        @user_for.should_not_receive(:karma)
        helper.karma_block_for @user_for
      end
    end
    
    describe "when user can edit karma" do
      before :each do
        @current_user.stub!(:karma_viewer).and_return false
        @current_user.stub!(:karma_editor).and_return true
      end
    
      it "should contain two links" do
        helper.should_receive(:link_to).twice.and_return "ok"
        helper.karma_block_for @user_for
      end
      
      describe "but when requested block for him" do
        before :each do
          @user_for = @current_user
        end
      
        it "shouldn't contain any links" do
          helper.should_not_receive(:link_to)
          helper.karma_block_for @user_for
        end
      end
    end
    
    describe "when user can't edit karma" do
      before :each do
        @current_user.stub!(:karma_viewer).and_return false
        @current_user.stub!(:karma_editor).and_return false
      end
    
      it "shouldn't contain any links" do
        should_not_receive(:link_to)
        helper.karma_block_for @user_for
      end
    end
  end
end
