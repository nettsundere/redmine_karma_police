require File.expand_path('../../spec_helper', __FILE__)

describe ApplicationController do
  it "User model should be extended" do
    User.included_modules.should include UserExtension
  end
end
