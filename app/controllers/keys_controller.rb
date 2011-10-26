class KeysController < ApplicationController
  load_and_authorize_resource
  
  def index
    @keys = Key.where("user_id = ?", current_user.id)
  end
  
  def show
    @key = Key.find(params[:id])
    
    if session[:key_password]
      @key_password = session[:key_password]
      session[:key_password] = nil
    end
  end
  
  def new
    @key = Key.new
  end
  
  def create
    @key = Key.new(params[:key])

    @key.user_id = current_user.id

    if @key.save
      @key.generate_key(@key.password)
      redirect_to @key, notice: 
        "Key was successfully created.<br />Remember this password,\
        we will not store it: <strong>#{@key.password}</strong>".html_safe
    else
      render action: 'new'
    end
  end
  
  def edit
    @key = Key.find(params[:id])
  end
  
  def update
    @key = Key.find(params[:id])
    if @key.update_attributes(params[:key])
      notice = ''
      if !params[:key][:password].blank?
        @key.update_password(params[:key][:old_password], params[:key][:password])
        notice = "Remember the password, we will not store it: <strong>#{params[:key][:password]}</strong>"
      end
      redirect_to @key, notice: "Key was successfully updated. #{notice}".html_safe
    else
      render action: 'edit'
    end
  end
  
  
  def destroy
    @key = Key.find(params[:id])
    
    if !@key.certificates.empty?
      redirect_to @key, alert: 'First you must remove all assigned certificates.'
    elsif !@key.signs.empty?
      redirect_to @key, alert: 'First you must remove all assigned signs.'
    else
      @key.destroy
      redirect_to keys_url
    end
  end

  def show_certificates
    @key = Key.find(params[:id])
    @certificates = Certificate.where("key_id = ?", @key.id)
  end
end
