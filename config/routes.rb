Rails.application.routes.draw do
  devise_for :users

  root 'pages#home'

  # infinity mode
  get '/infinity'                 => 'game_modes/infinity#index'
  get '/infinity/puzzles'         => 'game_modes/infinity#puzzles'
  post '/infinity/puzzles'        => 'game_modes/infinity#puzzle_solved'

  # speedrun mode
  get '/speedrun'                 => 'game_modes/speedrun#index'
  get '/speedrun/puzzles'         => 'game_modes/speedrun#puzzles'
  post '/speedrun'                => 'game_modes/speedrun#complete'

  # repetition mode
  get '/level-:level_num'         => 'game_modes/repetition#index'
  get '/level-:level_num/puzzles' => 'game_modes/repetition#puzzles'
  post '/levels/:id/attempt'      => 'game_modes/repetition#attempt'
  post '/levels/:id/complete'     => 'game_modes/repetition#complete'

  # pages
  get '/positions'             => 'pages#positions'
  get '/positions/:id'         => 'pages#position'
  get '/position'              => 'pages#position'
  get '/pawn-endgames'         => 'pages#pawn_endgames'
  get '/scoreboard'            => 'pages#scoreboard'
  get '/about'                 => 'pages#about'

  static_routes = StaticRoutes.new
  static_routes.route_map!
  static_routes.route_paths.each do |route|
    get route => "pages#defined_position"
  end

  get '/levels'                => 'levels#index'

  # admin routes
  get '/level-:level_num/edit' => 'levels#edit'
  put '/level-:level_num'      => 'levels#update'
  get '/puzzles/search'        => 'puzzles#search'
  get '/puzzles/:id'           => 'puzzles#show'

  # user routes
  get '/:username'             => 'users#show'
end
