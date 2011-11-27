require File.expand_path('../../spec_helper', __FILE__)

describe UsersController do
  fixtures :users
  
  describe "#delete action" do
  
    before :each do
      @m = mock_model(User)
      @m.stub!(:admin?).and_return true
      @m.stub!(:logged?).and_return true
      @m.stub!(:language).and_return :en
      User.stub!(:current).and_return(@m)
    end
  
    it "should cause votes made by the user to be taken back in result of destroy" do
      Vote.should_receive(:take_back_all_from).once
      delete :destroy, :id => 1
    end
  end
end
