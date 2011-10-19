require 'spec_helper'

describe Certificate do
  before(:all) do
    User.destroy_all
    @user = Factory(:user)
    
    Key.destroy_all
    @key = Factory(:key)
    @key.generate_key(@key.password)
  end
  
  before(:all) do
    Certificate.destroy_all
  end
  
  before(:each) do
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
  
  describe "selfsigned certificates creation" do
    before(:each) do
      Certificate.destroy_all
    end
    
    it "should not create invalid certificates" do
      Certificate.new(@root_attr.merge(email: 'foobar.com')).should_not be_valid
    end
    
    it "should create valid certificates" do
      certificate = Certificate.create!(@root_attr).should be_true
      certificate.title.should eq(@root_attr[:title])
      certificate.common_name.should eq(@root_attr[:common_name])
      certificate.email.should eq(@root_attr[:email])
      certificate.key_id.should eq(@root_attr[:key_id])
      certificate.user_id.should eq(@root_attr[:user_id])
      certificate.days.should eq(@root_attr[:days])
      certificate.locality.should eq(@root_attr[:locality])
      certificate.state.should eq(@root_attr[:state])
      certificate.organization.should eq(@root_attr[:organization])
      certificate.organization_unit.should eq(@root_attr[:organization_unit])
    end
    
    it "should create correct certificates with some invalid data" do
      Certificate.create!(@root_attr.merge(user_id: -1)).user.should eq(@user)
      Certificate.create!(@root_attr.merge(days: -1)).days.should eq(1)
      Certificate.create!(@root_attr.merge(key_id: -1)).key.should eq(@key)
    end
    
    it "should create certificates with serial = 0" do
      certificate = Certificate.create!(@root_attr).should be_true
      certificate.serial.should eq(0)
    end
    
    it "should generate certificate body" do
      certificate = Certificate.create!(@root_attr).should be_true
      certificate.generate_certificate(@key.password).should be_true
      certificate.body.should_not be_blank
      certificate.sha.should_not be_blank
    end
  end
  
  describe "issued ca certificates creation" do
    before(:each) do
      Certificate.destroy_all
      @root = Certificate.create!(@root_attr).should be_true
      @root.update_attribute(:ca, true)
      @root.serial.should eq(0)
      @root.certificate_id.should eq(0)
      @root.generate_certificate(@key.password)
    end
    
    it "should generate request and certificate by request" do
      certificate = Certificate.create!(@ca_attr.merge(certificate_id: @root.id)).should be_true
      certificate.generate_certificate(@key.password).should be_true
      certificate.body.should_not be_blank
      request = certificate.body
      serial = @root.serial
      
      @root.sign_certificate(@key.password, certificate.id, certificate.days, true).should be_true      
      certificate.reload
      certificate.ca.should be_true
      certificate.body.should_not be_blank
      certificate.body.should_not eq(request)
      certificate.days.should eq(@ca_attr[:days])
      @root.serial.should eq(serial + 1)
    end
  end
  
  describe "client ca certificates creation" do
    before(:each) do
      Certificate.destroy_all
      @root = Certificate.create!(@root_attr).should be_true
      @root.update_attribute(:ca, true)
      @root.generate_certificate(@key.password)
      
      @ca = Certificate.create!(@ca_attr.merge(certificate_id: @root.id)).should be_true
      @ca.generate_certificate(@key.password).should be_true
      @root.sign_certificate(@key.password, @ca.id, @ca.days, true).should be_true
      @ca.update_attribute(:ca, true)
      
      @ca.reload
      @root.reload
    end
    
    it "should create client certificate" do
      @client = Certificate.create!(@client_attr.merge(certificate_id: @ca.id))
      @client.generate_certificate(@key.password).should be_true
      request = @client
      serial = @ca.serial
      
      @ca.sign_certificate(@key.password, @client.id, @ca.days).should be_true
      
      @client.body.should_not be_blank
      @client.body.should_not eq(request)
      @ca.serial.should eq(serial + 1)
    end
  end
end















