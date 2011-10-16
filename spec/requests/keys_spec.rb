require 'spec_helper'

describe "Keys" do
  before(:each) do
    User.destroy_all
    Key.destroy_all
    @user = Factory(:user)
    visit login_path
    page.should have_content("Log in")
    fill_in "Email", with: @user.email
    fill_in "Password", with: @user.password
    click_button "Log in"
    page.should have_content("Welcome back, #{@user.first_name}")
    visit root_url
  end
  
  describe "keys creation" do
    before(:each) do
      @attr = {
        title: 'Test key',
        password: 'secret',
        password_confirmation: 'secret'
      }
    end
    
    it "should create new key" do
      visit new_key_path
      fill_in "Title", with: @attr[:title]
      fill_in "Password", with: @attr[:password]
      fill_in "Password confirmation", with: @attr[:password_confirmation]
      click_button "Generate key"
      page.should have_content("Key was successfully created.")
      page.should have_content("Remember this password, we will not store it: #{@attr[:password]}")
      page.should have_content(Key.first.body)
      page.should have_content(Key.first.public_body)
    end
  end
  
  describe "key update" do
    before(:each) do
      @attr = {
        title: 'Test key',
        password: 'secret',
        password_confirmation: 'secret'
      }
      @key = Key.create!(@attr)
      @key.update_attribute(:user_id, @user.id)
      @key.generate_key(@attr[:password])
    end
    
    it "should update key with correct old password" do
      visit edit_key_path(@key)
      fill_in "Title", with: "New super title"
      fill_in "Password", with: "qwerty"
      fill_in "Password confirmation", with: "qwerty"
      click_button "Update key"
      page.should have_content("Old password is wrong")
      
      fill_in "Password", with: "qwerty"
      fill_in "Password confirmation", with: "qwerty"
      fill_in "Password", with: "qwerty"
      fill_in "Old password", with: @attr[:password]
      click_button "Update key"
      page.should have_content("New super title")
      page.should have_content("Key was successfully updated. Remember the password, we will not store it: qwerty")
      
      click_link "Edit"
      fill_in "Password", with: @attr[:password]
      fill_in "Password confirmation", with: @attr[:password]
      fill_in "Old password", with: "qwerty"
      fill_in "Title", with: @attr[:title]
      click_button "Update key"
      page.should have_content(@attr[:title])
      page.should have_content("Key was successfully updated. Remember the password, we will not store it: #{@attr[:password]}")
    end
  end
end
