require 'spec_helper'

describe Page do
  describe "main actions" do
    before(:all) do
      @user = Factory(:user)
      @attr = {
        title: 'Super Page',
        body: 'Super Page Content',
      }
    end
    
    it "should create valid page" do
      page = Page.new(@attr)
      page.user_id = @user.id
      page.should be_valid
      page.save.should be_true
      page.title.should eq(@attr[:title])
      page.body.should eq(@attr[:body])
      page.sha.should_not be_blank
    end
  end
end
