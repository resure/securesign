require 'spec_helper'

describe "Certificates" do
  before(:all) do
    User.destroy_all
    Key.destroy_all
    Certificate.destroy_all    
    @user = Factory(:user)
    @key = Factory(:key)
    @key.generate_key(@key.password)
    
    @root_attr = {
      title: 'Root CA Certificate',
      common_name: 'Root CA Certificate',
      email: 'root@securesignhq.dev',
      key_id: @key.id,
      user_id: @user.id,
      days: 365,
      locality: 'Moscow',
      state: 'Central Federal District',
      organization: 'SecureSign',
      organization_unit: 'SecureSign Root Certification Authority'
    }
    
    @ca_attr = {
      title: 'Issued CA certificate',
      common_name: 'Issued CA certificate',
      email: 'ca@securesignhq.dev',
      key_id: @key.id,
      user_id: @user.id,
      days: 365,
      locality: 'Moscow',
      state: 'Central Federal District',
      organization: 'SecureSign',
      organization_unit: 'SecureSign Certification Authority'
    }
    
    @client_attr = {
      title: 'Issued not CA certificate',
      common_name: 'Issued not CA certificate',
      email: 'client@securesignhq.dev',
      key_id: @key.id,
      user_id: @user.id,
      days: 365,
      locality: 'Moscow',
      state: 'Central Federal District',
      organization: 'SecureSign',
      organization_unit: 'SecureSign Web Services'
    }
  end
  
  describe "root certificate creation" do
    it "should create certificate" do
      login @user
      
      visit new_certificate_path
      fill_in 'Title', with: @root_attr[:title]
      fill_in 'Key password', with: @key.password
      fill_in 'Common name', with: @root_attr[:common_name]
      fill_in 'Email', with: @root_attr[:email]
      fill_in 'Organization', with: @root_attr[:organization]
      fill_in 'Organization unit', with: @root_attr[:organization_unit]
      fill_in 'Country', with: @root_attr[:country]
      fill_in 'State', with: @root_attr[:state]
      fill_in 'Days', with: @root_attr[:days]
      fill_in 'Locality', with: @root_attr[:locality]
      click_button 'Create certificate'
      
      page.should have_content('Certificate was successfully updated.')
      page.should have_content('Root Certificate')
      page.should have_content('CA certificate')
      page.should have_content('-----BEGIN CERTIFICATE-----')
      page.should have_content('-----END CERTIFICATE-----')
      page.should have_content(@root_attr[:common_name])
      page.should have_content(@root_attr[:days])
      page.should have_content(@root_attr[:title])
      page.should have_content(@root_attr[:email])
      page.should have_content("Key ID: #{@key.id}")    
    end
  end
  
  describe "ca and client certificate creation" do
    before(:all) do
      Certificate.destroy_all
      @root_certificate = Certificate.create!(@root_attr)
      @root_certificate.generate_certificate(@key.password)
    end
    
    it "should create client ca certificate" do
      login @user
      
      visit new_certificate_path
      fill_in 'Title', with: @ca_attr[:title]
      fill_in 'Key password', with: @key.password
      fill_in 'Certificate', with: @root_certificate.id
      fill_in 'Common name', with: @ca_attr[:common_name]
      fill_in 'Email', with: @ca_attr[:email]
      fill_in 'Organization', with: @ca_attr[:organization]
      fill_in 'Organization unit', with: @ca_attr[:organization_unit]
      fill_in 'Country', with: @ca_attr[:country]
      fill_in 'State', with: @ca_attr[:state]
      fill_in 'Days', with: @ca_attr[:days]
      fill_in 'Locality', with: @ca_attr[:locality]
      click_button 'Create certificate'
      
      page.should have_content('Certificate was successfully updated.')
      page.should_not have_content('Root Certificate')
      page.should have_content("Waiting approving from #{@root_certificate.common_name}")
      page.should have_content('CA certificate')
      page.should have_content('-----BEGIN CERTIFICATE REQUEST-----')
      page.should have_content('-----END CERTIFICATE REQUEST-----')
      page.should have_content(@ca_attr[:common_name])
      page.should have_content(@ca_attr[:days])
      page.should have_content(@ca_attr[:title])
      page.should have_content(@ca_attr[:email])
      page.should have_content("Key ID: #{@key.id}")
      
      click_link 'Sign this request'
      page.should have_content("Signing '#{@ca_attr[:common_name]}' by '#{@root_certificate.common_name}'")
      fill_in 'key_password', with: @key.password
      check 'create_ca'
      click_button 'Sign'
      
      page.should have_content('Certificate successfully signed.')
      page.should have_content("Issued by #{@root_certificate.common_name}")
      page.should have_content('Certificate successfully signed.')
      page.should have_content('CA certificate')
      page.should_not have_content('Root Certificate')
      page.should have_content('-----BEGIN CERTIFICATE-----')
      page.should have_content('-----END CERTIFICATE-----')
    end
  end
end









