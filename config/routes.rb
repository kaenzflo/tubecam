Rails.application.routes.draw do
  devise_for :users, :controllers => { registrations: 'registrations' }
  resources :tubecam_devices
  resources :media
  resources :sequences
  resources :users

  get '/standorte' => 'maps#index', as: "maps"
  get '/projekt', to: 'pages#project', as: "project"
  get '/projekt/dataexport', to: 'pages#dataexport', as: "dataexport"
  get '/kontakt', to: 'pages#contact', as: "contact"
  get '/dashboard', to: 'pages#dashboard', as: "dashboard"

  get '/annotations' => 'annotations#index', as: "annotations"
  get '/annotations/new' => 'annotations#new', as: "new_annotation"
  get '/annotations/specific/:id' => 'annotations#specific', as: "specific_annotation"
  get '/annotations/done' => 'annotations#done'
  get '/annotations/destroy/:id' => 'annotations#destroy'
  post '/annotations' => 'annotations#create'

  # Deactivate instead of Destroy
  get '/sequences/deactivate/:id' => 'sequences#deactivate'
  get '/sequences/activate/:id' => 'sequences#activate'
  get '/sequences/verify/:id' => 'sequences#verify', as: "verify_annotation"
  get '/sequences/unverify/:id' => 'sequences#unverify', as: "unverify_annotation"
  get '/tubecam_devices/deactivate/:id' => 'tubecam_devices#deactivate'
  get '/tubecam_devices/activate/:id' => 'tubecam_devices#activate'
  get '/users/deactivate/:id' => 'users#deactivate'
  get '/users/activate/:id' => 'users#activate'

  root 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
