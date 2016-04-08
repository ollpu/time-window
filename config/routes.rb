Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  mount ActionCable.server => '/cable'
  root to: 'index#index', as: 'index'
  resources :shows
  get '/shows/:id/regen', to: 'shows#regen', as: 'regen_show'
  post '/shows/:id/owners', to: 'shows#owners', as: 'man_owners'
  get '/l/:urlid', to: 'shows#live_client', as: 'live_client'
  
  resources :users
  get '/login', to: 'sessions#new', as: 'login'
  post '/login', to: 'sessions#create', as: 'auth'
  get '/logout', to: 'sessions#destroy', as: 'logout'
  get '/register', to: 'users#new', as: 'register'
end
