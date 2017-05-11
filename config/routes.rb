Rails.application.routes.draw do
  devise_for :users, :controllers => { registrations: 'registrations' }
  resources :tubecam_devices
  resources :media
  resources :sequences
  resources :users

  get '/standorte' => 'maps#index', as: "maps"
  get '/projekt', to: 'pages#project', as: "project"
  get '/kontakt', to: 'pages#contact', as: "contact"
  get '/dashboard', to: 'pages#dashboard', as: "dashboard"

  get '/annotations' => 'annotations#index', as: "annotations"
  get '/annotations/new' => 'annotations#new', as: "new_annotation"
  get '/annotations/specific' => 'annotations#specific', as: "specific_annotation"
  get '/annotations/done' => 'annotations#done'
  get '/annotations/destroy' => 'annotations#destroy'
  get '/annotations/confirm_verification' => 'annotations#confirm_verification'
  get '/annotations/delete_verification' => 'annotations#delete_verification'
  post '/annotations' => 'annotations#create'


  # Deactivate instead of Destroy
  get '/sequences/delete/:id' => 'sequences#delete'
  get '/sequences/activate/:id' => 'sequences#activate'
  get '/tubecam_devices/delete/:id' => 'tubecam_devices#delete'
  get '/tubecam_devices/activate/:id' => 'tubecam_devices#activate'

  root 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
