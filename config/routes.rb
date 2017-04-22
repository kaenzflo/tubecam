Rails.application.routes.draw do
  devise_for :users
  resources :media
  resources :tubecamstations
  resources :users

  root "welcome#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
