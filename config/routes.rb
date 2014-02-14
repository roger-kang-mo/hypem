Hypem::Application.routes.draw do
  
  root :to => 'hypem#index'

  resources :hypem

  get 'get_tracks' => 'hypem#query_tracks'
  get 'get_library' => 'hypem#get_library'

end