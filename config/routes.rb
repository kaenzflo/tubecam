Rails.application.routes.draw do
  resources :tubecam_devices
  devise_for :users, :controllers => { registrations: 'registrations' }
  resources :media
  resources :users

  get '/standorte' => 'maps#index', as: "maps"
  get '/projekt', to: 'pages#project', as: "project"
  get '/kontakt', to: 'pages#contact', as: "contact"

  get '/annotations/new' => 'annotations#new'
  post '/annotations' => 'annotations#create'

  root 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
