class SignsController < ApplicationController
  before_filter :authenticate!, :load_user_certificates
  
  def signing_page
    @page = Page.find(params[:id])
    @sign = Sign.new
  end
  
  def sign_page
    @page = Page.find(params[:id])
    
    authorize! :sign, @page
    
    @sign = Sign.new
    @sign.key_id = Certificate.find(params[:certificate_id]).key_id
    @sign.certificate_id = params[:certificate_id]
    @sign.signable = @page

    if !@sign.key.authenticate(params[:key_password])
      redirect_to @page, alert: 'Wrong key password.'
    elsif @sign.save
      @sign.sign(params[:key_password])
      redirect_to @page, notice: 'Successfully signed.'
    else
      redirect_to pages_url, alert: 'Access denied.'
    end
  end
  
  def verify_sign
    begin
      @sign = Sign.find_by_sha(params[:sha])
      @sign.signable.generate_digest
      authorize! :verify, @sign
    rescue ActiveRecord::RecordNotFound
      redirect_to root_url, alert: 'Sign not found.'
    end
    @verifying_data = @sign.verify_sign
  end
  
  def destroy
    @sign = Sign.find_by_sha(params[:sha])
    signable = @sign.signable
    if @sign.key.user_id == current_user.id
      @sign.destroy
      redirect_to signable
    else
      redirect_to root_url, alert: 'Access denied'
    end
  end
  
  
  private
  
  def load_user_certificates
    @user_certificates = []
    
    Certificate.where("user_id = ?", current_user.id).each do |certificate|
      @user_certificates << ["#{certificate[:title]} &mdash; #{certificate.key[:title]}".html_safe, certificate[:id]]
    end
  end
end
