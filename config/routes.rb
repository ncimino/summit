Summit::Application.routes.draw do

  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users

  resources :websites
  match 'websites/:id/run_step/:step' => 'websites#run_step', :as => 'run_step'
  resources :pages, :only => :show

  root :to => "pages#show", :id => 0

end
