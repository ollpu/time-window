Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  mount ActionCable.server => '/cable'
  root to: 'index#index', as: 'index'
  resources :shows
  get '/shows/:id/regen', to: 'shows#regen', as: 'regen_show'
  get '/l/:urlid', to: 'shows#live_client', as: 'live_client'
end
