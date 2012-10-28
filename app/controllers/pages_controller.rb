class PagesController < ApplicationController

  def show
    if params[:id] == 0
      @page = Page.find_by_name('home') || Page.first
    else
      @page = Page.find(params[:id])
    end
    redirect_to :admin_root unless @page
  end

end
