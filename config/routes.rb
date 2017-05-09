Rails.application.routes.draw do
  devise_for :users, :controllers => { registrations: 'registrations' }
  resources :tubecam_devices
  resources :media
  resources :users

  get '/standorte' => 'maps#index', as: "maps"
  get '/projekt', to: 'pages#project', as: "project"
  get '/kontakt', to: 'pages#contact', as: "contact"

  get '/annotations/new' => 'annotations#new'
  get '/annotations/specific' => 'annotations#specific'
  post '/annotations' => 'annotations#create'

  # Deactivate instead of Destroy
  get '/media/delete/:id' => 'media#delete'
  get '/media/activate/:id' => 'media#activate'
  get '/tubecam_devices/delete/:id' => 'tubecam_devices#delete'
  get '/tubecam_devices/activate/:id' => 'tubecam_devices#activate'

  root 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
