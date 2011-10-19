require "spec_helper"
require "cancan/matchers"

describe "Ability" do
  before(:each) do
    User.destroy_all
  end
  
  describe "as guest" do
    before(:each) do
      @ability = Ability.new(nil)
    end
    
    it "can inly view and create users" do      
      @ability.should be_able_to(:login, User)
      @ability.should be_able_to(:create, User)
    end
    
    it "can access any info pages" do
      @ability.should be_able_to(:access, :info)
    end
  end
  
  describe "as normal user" do
    it "can update himself, but not other users" do
      user = Factory(:user)
      ability = Ability.new(user)
      ability.should be_able_to(:show, User.new)
      ability.should be_able_to(:logout, :users)
      ability.should be_able_to(:update, user)
      ability.should_not be_able_to(:update, User.new)
      ability.should_not be_able_to(:block, :users)
      
      ability.should_not be_able_to(:access, :keys)
      ability.should_not be_able_to(:create, :keys)
      ability.should_not be_able_to(:read, :keys, id: user.id)
      ability.should_not be_able_to(:update, :keys, id: user.id)
      ability.should_not be_able_to(:destroy, :keys, id: user.id)
      
      ability.should_not be_able_to(:access, :certificates)
      ability.should_not be_able_to(:create, :certificates)
      ability.should_not be_able_to(:read, :certificates, id: user.id)
      ability.should_not be_able_to(:update, :certificates, id: user.id)
      ability.should_not be_able_to(:destroy, :certificates, id: user.id)
    end
  end
  
  describe "as banned user" do
    before(:each) do
      @user = Factory(:user)
      @user.update_attribute(:block, true)
      @ability = Ability.new(@user)
    end

    it "cannot update profile" do
      @ability.should_not be_able_to(:update, @user)
    end
    
    it "cannot read other users profiles" do
      @ability.should be_able_to(:read, @user)
      @ability.should_not be_able_to(:read, User.new)
    end
  end
  
  describe "as admin" do
    it "can access all" do
      user = Factory(:user)
      user.update_attribute(:admin, true)
      ability = Ability.new(user)
      ability.should be_able_to(:access, :all)
      ability.should be_able_to(:update, User)
      ability.should be_able_to(:destroy, User)
      ability.should be_able_to(:block, User)
      
      ability.should be_able_to(:read, :keys)
      ability.should be_able_to(:update, :keys)
      ability.should be_able_to(:destroy, :keys)
      ability.should be_able_to(:read, Certificate)
      ability.should be_able_to(:update, Certificate)
      ability.should be_able_to(:destroy, Certificate)
    end
  end
end