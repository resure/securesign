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
  
  it "creates user with correct info" do
    User.create!(@attr).should be_true
    user = User.last
    user.email.should eq(@attr[:email])
    user.first_name.should eq(@attr[:first_name])
    user.last_name.should eq(@attr[:last_name])
    user.should eq(User.authenticate(@attr[:email], @attr[:password]))    
  end
  
  it "decline user creation without correct info" do
    User.new(@attr.merge(email: 'example.com')).should_not be_valid
    User.new(@attr.merge(first_name: 'ab')).should_not be_valid
    User.new(@attr.merge(last_name: 'ab')).should_not be_valid
    User.new(@attr.merge(password: 'qwerty')).should_not be_valid
    User.new(@attr.merge(password_confirmation: 'qwerty')).should_not be_valid
    User.create!(@attr)
    User.new(@attr).should_not be_valid
  end
  
  it "should authenticate user only with correct password" do
    User.create!(@attr)
    User.authenticate(@attr[:email], 'foobar').should_not be_true
    User.authenticate(@attr[:email], @attr[:password]).should be_true
  end
end
