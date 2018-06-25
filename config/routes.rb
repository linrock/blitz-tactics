Rails.application.routes.draw do
  devise_for :users

  root 'pages#home'

  # infinity mode
  get '/infinity'                => 'game_modes/infinity#index'
  get '/infinity/puzzles'        => 'game_modes/infinity#puzzles'
  post '/infinity/puzzles'       => 'game_modes/infinity#puzzle_solved'

  # speedrun mode
  get '/speedrun'                => 'game_modes/speedrun#index'
  get '/speedrun/puzzles'        => 'game_modes/speedrun#puzzles'
  post '/speedrun'               => 'game_modes/speedrun#complete'

  # repetition mode
  get '/repetition'              => 'game_modes/repetition#index'
  get '/level-:number'           => 'game_modes/repetition#index'
  get '/level-:number/puzzles'   => 'game_modes/repetition#puzzles'
  post '/level-:number/attempt'  => 'game_modes/repetition#attempt'
  post '/level-:number/complete' => 'game_modes/repetition#complete'

  # pages
  get '/positions'               => 'pages#positions'
  get '/positions/:id'           => 'pages#position'
  get '/position'                => 'pages#position'
  get '/pawn-endgames'           => 'pages#pawn_endgames'
  get '/scoreboard'              => 'pages#scoreboard'
  get '/about'                   => 'pages#about'

  # pre-defined position trainer routes
  static_routes = StaticRoutes.new
  static_routes.route_map!
  static_routes.route_paths.each do |route|
    get route => "pages#defined_position"
  end

  # user routes
  put '/users/me'                => 'users#update'
  get '/:username'               => 'users#show'
end
