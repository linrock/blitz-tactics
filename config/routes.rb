Rails.application.routes.draw do
  devise_for :users

  root 'home#index'

  # infinity mode
  get '/infinity'              => 'infinity#index'
  get '/infinity/puzzles'      => 'infinity#puzzles'
  post '/infinity/puzzles'     => 'infinity#puzzle_solved'

  # speedrun mode
  get '/speedrun'              => 'speedrun#index'
  get '/speedrun/puzzles'      => 'speedrun#puzzles'
  post '/speedrun'             => 'speedrun#complete'

  # repetition mode
  get '/level-:level_num'      => 'levels#show'
  post '/levels/:id/attempt'   => 'levels#attempt'
  post '/levels/:id/complete'  => 'levels#complete'

  # position trainer
  get '/positions/:id'         => 'positions#show'
  get '/positions'             => 'static#positions'
  get '/position'              => 'static#position'

  # misc routes
  get '/scoreboard'            => 'scoreboard#index'
  get '/levels'                => 'levels#index'

  # static routes
  get '/about'                 => 'static#about'
  get '/pawn-endgames'         => 'static#pawn_endgames'

  static_routes = StaticRoutes.new
  static_routes.route_map!
  static_routes.route_paths.each do |route|
    get route => "static#defined_position"
  end

  # admin routes
  get '/level-:level_num/edit' => 'levels#edit'
  put '/level-:level_num'      => 'levels#update'
  get '/puzzles/search'        => 'puzzles#search'
  get '/puzzles/:id'           => 'puzzles#show'

  # user routes
  get '/:username'             => 'users#show'
end
