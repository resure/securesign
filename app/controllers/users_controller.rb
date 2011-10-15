class UsersController < ApplicationController
  load_and_authorize_resource
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to root_url, notice: 'Signed up!'
    else
      render :new
    end
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def index
    @users = User.all
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    # TODO: check permissions
    
    if @user.update_attributes(params[:user].merge(password: nil, password_confirmation: nil))
      if current_user.admin? && @user != current_user
        @user.update_attribute(:admin, params[:user][:admin])
        @user.update_attribute(:block, params[:user][:block])
      end
      
      if !params[:user][:password].blank?
        if params[:user][:password] != params[:user][:password_confirmation]
          redirect_to edit_user_path(@user), alert: 'Password does\'t match the confirmation.'
        elsif !current_user.admin? && !@user.authenticate(params[:user][:old_password])
          redirect_to edit_user_path(@user), alert: 'Wrong old password.'
        else
          @user.password = params[:user][:password]
          @user.password_confirmation = params[:user][:password_confirmation]
          if @user.save
            redirect_to @user, notice: 'Profile was successfully updated.'
          else
            render action: 'edit'
          end
        end
      else
        redirect_to @user, notice: 'Profile was successfully updated.'
      end
      
    else
      render action: 'edit'
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    # TODO: check permissions
    redirect_to users_path, alert: 'You can\'t delete yourself.' if @user == current_user
    @user.destroy
    redirect_to users_path
  end

end
