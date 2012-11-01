class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :get_variables
  def get_variables
    @display_pages = Page.order("ordinal")
    @websites = Website.all
  end
end
