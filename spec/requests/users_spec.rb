require 'spec_helper'

describe "Users" do
  
  def login(user_attr)
    visit login_path
    page.should have_content("Log in")
    fill_in "Email", with: user_attr[:email]
    fill_in "Password", with: user_attr[:password]
    click_button "Log in"
    page.should have_content("Welcome back, #{user_attr[:first_name]}")
    visit root_url
  end
  
  def logout
    click_link "Log out"
  end
  
  before(:each) do
    User.destroy_all
  end
  
  describe "registration" do
    
    before(:each) do
      @attr = {
        email: 'test@securesignhq.dev',
        password: 'secret',
        password_confirmation: 'secret',
        first_name: 'Foo',
        last_name: 'Bar'
      }
    end
    
    it "sign up with correct info" do
      visit signup_path
      page.should have_content("Sign Up")
      fill_in "Email", with: @attr[:email]
      fill_in "First name", with: @attr[:first_name]
      fill_in "Last name", with: @attr[:last_name]
      fill_in "Password", with: @attr[:password]
      fill_in "Password confirmation", with: @attr[:password_confirmation]
      click_on "Sign Up"
      page.should have_content("Signed up!")
    end
    
    it "reject with invalid info" do
      visit signup_path
      page.should have_content("Sign Up")
      
      click_on "Sign Up"
      page.should have_content("Email is invalid")
      page.should have_content("First name is invalid")
      page.should have_content("Last name is invalid")
      
      fill_in "Email", with: @attr[:email]
      fill_in "First name", with: @attr[:first_name]
      fill_in "Last name", with: @attr[:last_name]
      
      click_on "Sign Up"
      page.should have_content("Password can't be blank")
      
      fill_in "Password", with: @attr[:password]
      fill_in "Password confirmation", with: 'qwerty'
      
      click_on "Sign Up"
      page.should have_content("Password doesn't match confirmation")
      
      fill_in "Password", with: @attr[:password]
      fill_in "Password confirmation", with: @attr[:password_confirmation]
      click_on "Sign Up"
      page.should have_content("Signed up!")
    end
  end

  describe "Authentication" do
    it "Authorize with correct password" do
      @attr = {
        email: 'test@securesignhq.dev',
        password: 'secret',
        password_confirmation: 'secret',
        first_name: 'Foo',
        last_name: 'Bar'
      }      
      
      User.destroy_all
      user = User.create!(@attr)
      
      login(@attr)
    end
    
    it "reject without correct password or email" do
      @attr = {
        email: 'test@securesignhq.dev',
        password: 'secret',
        password_confirmation: 'secret',
        first_name: 'Foo',
        last_name: 'Bar'
      }
      
      User.destroy_all
      user = User.create!(@attr)
      
      visit login_path
      page.should have_content("Log in")
      
      click_button "Log in"
      page.should have_content("Email or password was invalid")
      
      fill_in "Email", with: @attr[:email]
      fill_in "Password", with: 'qwerty'
      click_button "Log in"
      
      page.should have_content("Email or password was invalid")
      fill_in "Email", with: @attr[:email]
      click_button "Log in"
      page.should have_content("Email or password was invalid")
      fill_in "Password", with: 'qwerty'
      click_button "Log in"
      page.should have_content("Email or password was invalid")
      fill_in "Password", with: @attr[:password]
      click_button "Log in"
      page.should have_content("Welcome back, #{@attr[:first_name]}")
    end
    
    it "should show user profile" do
      @attr = {
        email: 'test@securesignhq.dev',
        password: 'secret',
        password_confirmation: 'secret',
        first_name: 'Foo',
        last_name: 'Bar'
      }      
      User.destroy_all
      user = User.create!(@attr)
      
      login(@attr)
      
      visit user_path(user)
      page.should have_content(@attr[:email])
      page.should have_content(@attr[:first_name])
      page.should have_content(@attr[:last_name])
    end
  end
  
  
  describe "profile editing" do
    before(:each) do
      User.destroy_all
      @user_attr = {
        email: 'user@securesignhq.dev',
        password: 'secret',
        password_confirmation: 'secret',
        first_name: 'Test',
        last_name: 'User'
      }
      @user = User.create!(@user_attr)
    end
    
    it "should update profile" do
      login(@user_attr)
      visit edit_user_path(@user)
      page.should have_content("Danger zone")
      fill_in "Email", with: "new@example.com"
      fill_in "First name", with: "New"
      fill_in "Last name", with: "Name"
      click_button "Update profile"
      page.should have_content("new@example.com")
      page.should have_content("New")
      page.should have_content("Name")
    end
    
    it "should update password only with correct old password" do
      login(@user_attr)
      visit edit_user_path(@user)
      
      page.should have_content("Danger zone")
      fill_in "Password", with: "qwerty"
      click_button "Update profile"
      page.should have_content("Password does't match the confirmation.")
      
      fill_in "Password", with: "qwerty"
      fill_in "Password confirmation", with: "qwerty"
      click_button "Update profile"
      
      page.should have_content("Wrong old password.")
      fill_in "Password", with: "qwerty"
      fill_in "Password confirmation", with: "qwerty"
      fill_in "Old password", with: @user_attr[:password]
      click_button "Update profile"
      page.should have_content("Profile was successfully updated.")
      
      logout
      login(@user_attr.merge(password: 'qwerty'))
    end
  end
  
  
  describe "admin functions" do
    before(:each) do
      User.destroy_all
      @admin_attr = {
        email: 'admin@securesignhq.dev',
        password: 'secret',
        password_confirmation: 'secret',
        first_name: 'Admin',
        last_name: 'User'
      }
      @user_attr = {
        email: 'user@securesignhq.dev',
        password: 'secret',
        password_confirmation: 'secret',
        first_name: 'Test',
        last_name: 'User'
      }
      @user = User.create!(@user_attr)
      @admin = User.create!(@admin_attr)
      @admin.update_attribute(:admin, true)
    end
    
    it "should update user profile without old password" do
      login(@admin_attr)
      visit edit_user_path(@user)
      fill_in "Password", with: "qwerty"
      fill_in "Password confirmation", with: "qwerty"
      check "Block"
      click_button "Update profile"
      page.should have_content("Profile was successfully updated.")
      logout
      
      login(@user_attr.merge(password: 'qwerty'))
      page.should have_content("You account is blocked.")
    end
  end
end
