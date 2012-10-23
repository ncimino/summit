Summit::Application.routes.draw do

  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users, :controllers => {:registrations => "registrations"}

  resources :websites

  get "sessions/new"
  get "registrations/edit"
  get "registrations/new"
  get "authentications/index"
  get "authentications/create"
  get "authentications/destroy"

  match "/auth/failure" => "authentications#failure"
  match "/auth/:provider/callback" => "authentications#create"

  root :to => "pages#show", :id => 0

  match "pages/:id" => "pages#show", :as => :page

end
