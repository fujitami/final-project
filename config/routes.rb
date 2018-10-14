Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
  }
  root to:'tags#index'
  resources :how_to, only: [:index]
  post 'artists/tagged/:id', to: 'artists#tagged_search'
  resources :artists, only: [:show]
  resources :albums, only: [:create, :show]
  resources :tags, only: [:index, :show]
  resources :users, only: [:show]
end
