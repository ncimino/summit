class PagesController < ApplicationController

  # GET /pages/1
  # GET /pages/1.json
  def show
    if params[:id] == 0
      @page = Page.find_by_name('home') || Page.first
    else
      @page = Page.find(params[:id])
    end

    respond_to do |format|
      # show.html.erb
      if @page
        format.html
        format.json { render json: @page }
      else
        format.html { redirect_to :admin_root }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
        
    end
  end

end
