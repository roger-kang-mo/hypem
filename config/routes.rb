Hypem::Application.routes.draw do
  
  root to: 'hypem#index'

  resources :hypem

  get 'get_tracks' => 'hypem#get_tracks'

  resources :hypem_users
  resources :hypem_playlists
  resources :hypem_tracks
  resources :emails

  get '/:username' => 'hypem#index'
  post '/hypem_tracks/:id/add_to_playlist' => 'hypem_tracks#add_to_playlist'
  match '/add_email' => 'emails#add_email'
end