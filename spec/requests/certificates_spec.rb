require 'spec_helper'

describe "Certificates" do
  describe "root certificate creation" do
    before(:all) do
      login
      @key = Factory(:key, user_id: current_user.id)
      @key.generate_key(@key.password)
      @key.update_attribute(:user_id, current_user.id)

      @root_attr = {
        title: 'Root CA Certificate',
        common_name: 'Root CA Certificate',
        email: 'root@securesignhq.dev',
        key_id: @key.id,
        user_id: current_user.id,
        days: 365,
        locality: 'Moscow',
        state: 'Central Federal District',
        organization: 'SecureSign',
        organization_unit: 'SecureSign Root Certification Authority'
      }
      
      @ca_attr = {
        title: 'CA Certificate',
        common_name: 'CA Certificate',
        email: 'ca@securesignhq.dev',
        key_id: @key.id,
        user_id: current_user.id,
        days: 365,
        locality: 'Moscow',
        state: 'Central Federal District',
        organization: 'SecureSign',
        organization_unit: 'SecureSign Certification Authority'
      }
    end
    
    it "should create certificate" do
      visit new_certificate_path
      fill_in 'Title', with: @root_attr[:title]
      fill_in 'Key password', with: @key.password
      fill_in 'Common name', with: @root_attr[:common_name]
      fill_in 'Email', with: @root_attr[:email]
      fill_in 'Organization', with: @root_attr[:organization]
      fill_in 'Organization unit', with: @root_attr[:organization_unit]
      select 'Russia', from: 'Country'
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
      
      @root_certificate = Certificate.last
      
      visit new_certificate_path
      
      fill_in 'Title', with: @ca_attr[:title]
      fill_in 'Key password', with: @key.password
      select @key.title, from: 'key_id'
      select @root_certificate.title, from: 'certificate_id'
      fill_in 'Common name', with: @ca_attr[:common_name]
      fill_in 'Email', with: @ca_attr[:email]
      fill_in 'Organization', with: @ca_attr[:organization]
      fill_in 'Organization unit', with: @ca_attr[:organization_unit]
      select 'Russia', from: 'Country'
      fill_in 'State', with: @ca_attr[:state]
      fill_in 'Days', with: @ca_attr[:days]
      fill_in 'Locality', with: @ca_attr[:locality]
      click_button 'Create certificate'

      page.should have_content('Certificate was successfully updated.')
      page.should_not have_content('Root Certificate')
      page.should have_content("Waiting approving from #{@root_certificate.common_name}")
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
