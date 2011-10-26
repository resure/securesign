require 'spec_helper'

describe Sign do
  before(:all) do
    @user = Factory(:user)
    @key = Factory(:key, user_id: @user.id)
    @key.generate_key(@key.password)
    @certificate = Factory(:certificate, user_id: @user.id, key_id: @key.id)
    @certificate.generate_certificate(@key.password)
  end
  
  it "should create valid sign" do
    page = Factory(:page)
    sign = Sign.new(key_id: @key.id, certificate_id: @certificate.id)
    sign.signable = page
    sign.should be_valid
    sign.save
    sign.reload
    sign.sign(@key.password).should be_true
    sign.body.should_not be_blank
    page.sign.should eq(sign)
  end
end
