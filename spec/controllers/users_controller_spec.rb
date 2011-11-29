require File.expand_path('../../spec_helper', __FILE__)

describe UsersController do
  describe "#delete action" do
  
    before :each do
      user = mock_model User 
      user.stub!(:admin?).and_return true
      user.stub!(:logged?).and_return true
      user.stub!(:language).and_return :en
      User.stub!(:current).and_return user
    end
  
    it "should cause votes made by the user to be taken back in result of destroy" do
      KarmaVote.should_receive(:take_back_all_from).once
      delete :destroy, :id => 1
    end
  end
end
