Hypem::Application.routes.draw do
  
  root to: 'hypem#index'

  resources :hypem

  get 'get_tracks' => 'hypem#get_tracks'

  resources :hypem_users
  resources :hypem_playlists
  resources :hypem_tracks

  get '/:username' => 'hypem#index'
end