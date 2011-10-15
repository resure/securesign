require 'spec_helper'

describe "Users" do
  
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
    it "Authorize with correct password", focus: true do
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
      fill_in "Email", with: @attr[:email]
      fill_in "Password", with: @attr[:password]
      click_button "Log in"
      page.should have_content("Welcome back, #{@attr[:first_name]}")
    end
    
    it "reject without correct password or email", focus: true do
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
  end
end
