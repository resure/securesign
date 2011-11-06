class CertificatesController < ApplicationController
  load_and_authorize_resource
  
  def index
    @certificates = Certificate.where("user_id = ?", current_user.id)
  end
  
  def show
    @certificate = Certificate.find(params[:id])
  end
  
  def new
    @certificate = Certificate.new
    load_certificates
    load_user_keys
  end
  
  def create
    @certificate = Certificate.new(params[:certificate].merge(key_id: params[:key_id], user_id: current_user.id, certificate_id: params[:certificate_id]))
    load_user_keys
    
    @certificate.certificate_id ||= 0
    @certificate.user_id = current_user.id
    
    if @certificate.save
      @certificate.generate_certificate(@certificate.key_password)
      redirect_to @certificate, notice: 'Certificate was successfully updated.'
    else
      render action: "new"
    end
  end
  
  def edit
    @certificate = Certificate.find(params[:id])
  end
  
  def update
    @certificate = Certificate.find(params[:id])
    
    if @certificate.update_attributes(params[:certificate])
      redirect_to @certificate, notice: 'Certificate was successfully updated.'
    else
      render action: "edit"
    end
  end
  
  def destroy
    @certificate = Certificate.find(params[:id])
    
    if !@certificate.certificates.empty?
      redirect_to @certificate, alert: 'First you must remove all assigned certificates.'
    elsif !@certificate.signs.empty?
      redirect_to @certificate, alert: 'First you must remove all assigned signs.'
    else
      @certificate.destroy
      redirect_to certificates_url
    end
  end
  
  def show_requests
   @certificate = Certificate.find(params[:id])
   @requests = Certificate.where("certificate_id = ?", @certificate.id)
  end
  
  def show_request
    @certificate = Certificate.find(params[:id])
    
    if @certificate.user_id != current_user.id\
      && Certificate.find(@certificate.certificate_id).user_id != current_user.id
      redirect_to @certificate, alert: 'Access denied'
    end
    
    @request = Certificate.find(params[:request_id])
  end
  
  def sign_request
    @certificate = Certificate.find(params[:id])
    @request = Certificate.find(params[:request_id])
    
    if @certificate.user_id != current_user.id\
        && Certificate.find(@certificate.certificate_id).user_id != current_user.id
      redirect_to @certificate, alert: 'Access denied'
    end
    
    if params[:create_ca]
      @request.update_attribute(:ca, true)
    end
    
    if @certificate.key.authenticate(params[:key_password])
      @certificate.sign_certificate(params[:key_password], params[:request_id], @request.days, params[:create_ca])
      redirect_to @request, notice: 'Certificate successfully signed.'
    else
      redirect_to @request, alert: 'Wront master key password.'
    end
  end
  
  def delete_request
    @certificate = Certificate.find(params[:id])
    @request = Certificate.find(params[:request_id])
    
    @request.destroy
  end
  
  def show_issued
    @certificate = Certificate.find(params[:id])
    @issued_certificates = Certificate.where("certificate_id = ?", @certificate.id)
  end

  def show_signs
    @certificate = Certificate.find(params[:id])
    @signs = Sign.where("certificate_id =?", @certificate.id)
  end
  
  
  private 
  
  def load_user_keys
    @user_keys = []
    
    Key.where("user_id = ?", current_user.id).each do |key|
      @user_keys << [key[:title], key[:id]]
    end
  end

  def load_certificates
    @certificates = [["Selfsigned certificate", 0]]
    
    Certificate.where("ca = ?", true).each do |certificate|
      @certificates << ["#{certificate[:common_name]} (#{certificate.user.first_name} #{certificate.user.last_name})", certificate[:id]]
    end
  end
end
