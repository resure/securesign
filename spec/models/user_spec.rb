require 'spec_helper'

describe User do
  before(:each) do
    User.destroy_all
    @attr = {
      email: 'test@securesignhq.dev',
      password: 'secret',
      password_confirmation: 'secret',
      first_name: 'Foo',
      last_name: 'Bar'
    }
  end
  
  it "should create new user with correct info" do
    User.create!(@attr).should be_true
    user = User.last
    user.email.should eq(@attr[:email])
    user.first_name.should eq(@attr[:first_name])
    user.authenticate(@attr[:password]).should be_true
  end
  
  it "should reject with invalid info" do
    User.new(@attr.merge(email: 'example.com')).should_not be_valid
    User.new(@attr.merge(first_name: '')).should_not be_valid
    User.new(@attr.merge(last_name: '')).should_not be_valid
    User.new(@attr.merge(password: '')).should_not be_valid
    User.new(@attr.merge(password_confirmation: 'qwerty')).should_not be_valid
  end
end
