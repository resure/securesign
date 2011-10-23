module AuthMacros
  def login(user = nil)
    user ||= Factory(:user)
    visit login_path
    page.should have_content("Log in")
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"
    page.should have_content("Welcome back, #{user.first_name}")
    visit root_url
    @_current_user = user
  end
  
  def logout
    visit logout_path
  end

  def current_user
    @_current_user
  end
end
