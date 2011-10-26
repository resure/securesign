require 'spec_helper'

describe "Pages" do
  before(:all) do
    @user = Factory(:user)
    @key = Factory(:key, user_id: @user.id)
    @key.generate_key(@key.password)
    @certificate = Factory(:certificate, user_id: @user.id, key_id: @key.id)
    @certificate.generate_certificate(@key.password)
    
    @attr = {
      title: 'Test Page',
      body: 'Test Page Body'
    }
  end
  
  it "should create page" do
    login(@user)

    visit new_page_path
    fill_in :page_title, with: @attr[:title]
    fill_in :page_body, with: @attr[:body]
    click_button 'Create page'
    
    page.should have_content('Page was successfully created.')
    page.should have_content(@attr[:title])
    page.should have_content(@attr[:body])
    page.should have_content("This page isn't signed.")
  end
  
  it "should sign page" do
    login @user
    new_page = Factory(:page, user_id: current_user.id, title: @attr[:title], body: @attr[:body])
    visit page_path(new_page)
    
    click_link 'Sign page'
    fill_in 'key_password', with: @key.password
    click_button 'Sign'
    
    page.should have_content("Successfully signed.")
    page.should have_content("This page is signed by #{@certificate.common_name}")
    click_link 'signed'
    page.should have_content('Success')
    visit page_path(new_page)
    click_link 'Delete sign'
    page.should have_content("This page isn't signed.")
  end
end
