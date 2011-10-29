class PagesController < ApplicationController
  load_and_authorize_resource
  
  def index
    @pages = Page.where("user_id = ?", current_user.id)
  end

  def show
    @page = Page.find(params[:id])
  end

  def new
    @page = Page.new
  end

  def create
    @page = current_user.pages.new params[:page]

    if @page.save
      redirect_to @page, notice: 'Page was successfully created.'
    else
      render action: "new"
    end
  end

  def edit
    @page = Page.find(params[:id])
  end

  def update
    @page = Page.find(params[:id])

    if @page.update_attributes(params[:page])
      @page.sign.destroy if @page.sign
      redirect_to @page, notice: 'Page was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @page = Page.find(params[:id])
    
    @page.destroy
    redirect_to pages_url
  end

end
