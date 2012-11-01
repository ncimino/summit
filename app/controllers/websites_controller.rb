class WebsitesController < ApplicationController
  before_filter :authenticate_user!

  def run_step
    @website = Website.find(params[:id])
    @checks = @website.get_checks
    if @website.run_step(params[:step])
      redirect_to @website, notice: "#{params[:step].humanize} generated successfully."
    else
      render action: "show"
    end
  end

  def index
    #@websites = Website.all #in app controller
  end

  def show
    @website = Website.find(params[:id])
    @checks = @website.get_checks
  end

  def new
    @website = Website.new
    @website.git_enabled = true
    @website.nginx_enabled = true
  end

  def edit
    @website = Website.find(params[:id])
  end

  def create
    @website = Website.new(params[:website])
    if @website.save
      redirect_to @website, notice: 'Website was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @website = Website.find(params[:id])

    if @website.update_attributes(params[:website])
      redirect_to @website, notice: 'Website was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @website = Website.find(params[:id])
    @website.destroy
    redirect_to websites_url
  end

end
