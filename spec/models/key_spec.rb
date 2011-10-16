require 'spec_helper'

describe Key do
  describe "key creation" do
    before(:each) do
      Factory(:user)
      Key.destroy_all
      @attr = {
        title: 'Test Key',
        password: 'secret',
        password_confirmation: 'secret'
      }
    end
    
    it "should not create key with invalid data" do
      Key.new(@attr.merge(title: '')).should_not be_valid
      Key.new(@attr.merge(password: '')).should_not be_valid
      Key.new(@attr.merge(password: 'qwerty')).should_not be_valid
    end
    
    it "should create key with valid data" do
      key = Key.new(@attr)
      key.should be_valid
      key.save
      key = Key.find(key.id)
      
      key.generate_key(@attr[:password]).should be_true
      key.title.should eq(@attr[:title])
      key.body.should_not be_blank
      key.public_body.should_not be_blank
      key.sha.should_not be_blank
    end
  end
  
  describe "password change" do
    before(:each) do
      Factory(:user)
      @key = Factory(:key)
      @key.generate_key(@key.password)
    end
    
    it "should reject password change without correct old password" do
      @key.password = 'qwerty'
      @key.password_confirmation = 'qwerty'
      @key.should_not be_valid
      
      old_key_data = @key.body
      
      @key.old_password = 'secret'
      @key.should be_valid
      @key.save.should be_true
      
      @key.update_password('secret', 'qwerty').should be_true
      @key.body.should_not be_blank
      @key.body.should_not eq(old_key_data)
      @key.authenticate('qwerty').should be_true
    end
  end
end
