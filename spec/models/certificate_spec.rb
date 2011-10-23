require 'spec_helper'

describe Certificate do
  describe "selfsigned certificates creation" do
    before(:all) do
      @user = Factory(:user)
      @key = Factory(:key, user_id: @user.id)
      @key.generate_key(@key.password)

      @attr = {
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
    end
    
    it "should not create invalid certificates" do
      Certificate.new(@attr.merge(email: 'foobar.com')).should_not be_valid
    end
    
    it "should create valid certificates" do
      certificate = Certificate.create!(@attr).should be_true
      certificate.title.should eq(@attr[:title])
      certificate.common_name.should eq(@attr[:common_name])
      certificate.email.should eq(@attr[:email])
      certificate.key_id.should eq(@attr[:key_id])
      certificate.days.should eq(@attr[:days])
      certificate.locality.should eq(@attr[:locality])
      certificate.state.should eq(@attr[:state])
      certificate.organization.should eq(@attr[:organization])
      certificate.organization_unit.should eq(@attr[:organization_unit])
    end
    
    it "should create correct certificates with some invalid data" do
      Certificate.create!(@attr.merge(days: -1)).days.should eq(1)
    end
    
    it "should create certificates with serial = 0" do
      certificate = Certificate.create!(@attr).should be_true
      certificate.serial.should eq(0)
    end
    
    it "should generate certificate body" do
      certificate = Certificate.create!(@attr).should be_true
      certificate.generate_certificate(@key.password).should be_true
      certificate.body.should_not be_blank
      certificate.sha.should_not be_blank
    end
  end
  
  describe "issued ca certificates creation" do    
    it "should generate request and certificate by request" do
      @user = Factory(:user)
      @key = Factory(:key, user_id: @user.id)
      @key.generate_key(@key.password)
      
      @attr = {
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
      @root = Certificate.create!(@attr)
      @root.generate_certificate(@key.password)

      certificate = Certificate.create!(@attr.merge(user_id: @user.id, key_id: @key.id, certificate_id: @root.id))
      certificate.generate_certificate(@key.password).should be_true
      
      certificate.body.should_not be_blank
      request = certificate.body
      serial = @root.serial
      
      @root.sign_certificate(@key.password, certificate.id, certificate.days, true).should be_true      
      certificate.reload
      certificate.ca.should be_true
      certificate.body.should_not be_blank
      certificate.body.should_not eq(request)
      certificate.days.should eq(@attr[:days])
      @root.serial.should eq(serial + 1)
    end
  end
end
