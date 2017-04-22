Rails.application.routes.draw do
  devise_for :users
  resources :media
  resources :tubecamstations
  resources :users

  get '/maps' => 'maps#index'
  get '/projekt', to: 'pages#project', as: "project"
  get '/kontakt', to: 'pages#contact', as: "contact"

  root 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
