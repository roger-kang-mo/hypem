Hypem::Application.routes.draw do
  
  root to: 'hypem#index'

  resources :hypem

  get 'get_tracks' => 'hypem#get_tracks'
  get 'get_users' => 'hypem#get_users'

  get '/:username' => 'hypem#index'
end