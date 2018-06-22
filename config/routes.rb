Rails.application.routes.draw do
  devise_for :users

  root 'home#index'

  # api routes - for players to track progress
  post '/api/levels/:id/attempt'   => 'api/levels#attempt'
  post '/api/levels/:id/complete'  => 'api/levels#complete'
  post '/api/infinity'             => 'api/infinity#solved_puzzle'

  get '/puzzles/search'        => 'puzzles#search'
  get '/puzzles/:id'           => 'puzzles#show'

  get '/about'                 => 'static#about'
  get '/positions'             => 'static#positions'
  get '/position'              => 'static#position'

  static_routes = StaticRoutes.new
  static_routes.route_map!
  static_routes.route_paths.each do |route|
    get route => "static#defined_position"
  end

  get '/pawn-endgames'         => 'static#pawn_endgames'
  # get '/rook-endgames'         => 'static#rook_endgames'

  get '/levels'                => 'levels#index'
  get '/scoreboard'            => 'scoreboard#index'

  resources :positions, :only => [:show]

  # infinity mode
  get '/infinity'              => 'infinity#index'
  get '/infinity/puzzles'      => 'infinity#puzzles'

  # speedrun mode
  get '/speedrun'              => 'speedrun#index'
  get '/speedrun/puzzles'      => 'speedrun#puzzles'

  # repetition mode
  get '/level-:level_num'      => 'levels#show'
  get '/level-:level_num/edit' => 'levels#edit'
  put '/level-:level_num'      => 'levels#update'

  get '/:username'             => 'users#show'
end
