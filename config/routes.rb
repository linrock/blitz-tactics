Rails.application.routes.draw do
  devise_for :users

  root 'home#index'

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
  post '/infinity/puzzles'     => 'infinity#puzzle_solved'

  # speedrun mode
  get '/speedrun'              => 'speedrun#index'
  get '/speedrun/puzzles'      => 'speedrun#puzzles'

  # repetition mode
  get '/level-:level_num'      => 'levels#show'
  get '/level-:level_num/edit' => 'levels#edit'
  put '/level-:level_num'      => 'levels#update'
  post '/levels/:id/attempt'   => 'levels#attempt'
  post '/levels/:id/complete'  => 'levels#complete'

  # user routes
  get '/:username'             => 'users#show'
end
