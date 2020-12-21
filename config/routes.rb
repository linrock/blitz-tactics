Rails.application.routes.draw do
  devise_for :users

  root 'pages#home'

  # infinity mode
  get '/infinity'                => 'game_modes/infinity#index'
  get '/infinity/puzzles.json'   => 'game_modes/infinity#puzzles_json'
  get '/infinity/puzzles'        => 'game_modes/infinity#puzzles'
  post '/infinity/puzzles'       => 'game_modes/infinity#puzzle_solved'

  # speedrun mode
  get '/speedrun'                => 'game_modes/speedrun#index'
  get '/speedrun/puzzles.json'   => 'game_modes/speedrun#puzzles_json'
  get '/speedrun/puzzles'        => 'game_modes/speedrun#puzzles'
  post '/speedrun'               => 'game_modes/speedrun#complete'

  # countdown mode
  get '/countdown'               => 'game_modes/countdown#index'
  get '/countdown/puzzles.json'  => 'game_modes/countdown#puzzles_json'
  post '/countdown'              => 'game_modes/countdown#complete'

  # haste mode
  get '/haste'                   => 'game_modes/haste#index'
  get '/haste/puzzles'           => 'game_modes/haste#puzzles'
  post '/haste'                  => 'game_modes/haste#complete'

  # threes mode
  get '/three'                  => 'game_modes/three#index'
  get '/three/puzzles'          => 'game_modes/three#puzzles'
  post '/three'                 => 'game_modes/three#complete'

  # repetition mode
  get '/repetition'              => 'game_modes/repetition#index'
  get '/level-:number'           => 'game_modes/repetition#index'
  get '/level-:number/puzzles'   => 'game_modes/repetition#puzzles'
  post '/level-:number/attempt'  => 'game_modes/repetition#complete_lap'
  post '/level-:number/complete' => 'game_modes/repetition#complete_level'

  # rated puzzles mode
  get '/rated'                   => 'game_modes/rated#index'
  get '/rated/puzzles.json'      => 'game_modes/rated#puzzles_json'
  get '/rated/puzzles'           => 'game_modes/rated#puzzles'

  get '/rated/attempts'          => 'game_modes/rated#puzzle_attempts_list'
  get '/rated/attempts/:id'      => 'game_modes/rated#puzzle_attempt'
  post '/rated/attempts'         => 'game_modes/rated#attempt'

  # more pages
  get '/scoreboard'              => 'pages#scoreboard'
  get '/about'                   => 'pages#about'

  # puzzle pages
  get '/puzzles'                 => 'puzzles#index'
  get '/puzzles/:puzzle_ids'     => 'puzzles#index'
  get '/p/:puzzle_id'            => 'puzzles#show'
  get '/p/:puzzle_id/edit'       => 'puzzles#edit'
  put '/p/:puzzle_id'            => 'puzzles#update'

  # puzzle reports
  get '/puzzle_reports'          => 'puzzle_reports#index'
  post '/puzzle_reports'         => 'puzzle_reports#create'

  # position pages
  get '/positions'               => 'pages#positions'
  get '/positions/:id'           => 'pages#position'
  get '/position'                => 'pages#position'
  get '/pawn-endgames'           => 'pages#pawn_endgames'
  get '/rook-endgames'           => 'pages#rook_endgames'
  get '/endgame-studies'         => 'pages#endgame_studies'
  get '/mate-in-two'             => 'pages#mate_in_two'

  # pre-defined position trainer routes
  static_routes = StaticRoutes.new
  static_routes.route_map!
  static_routes.route_paths.each do |route|
    get route => "pages#defined_position"
  end

  # customization routes
  get '/customize'               => 'users#customize_board'
  put '/customize'               => 'users#update_board'

  patch '/settings'              => 'user_settings#update'

  # user routes
  put '/users/me'                => 'users#update'
  get '/:username'               => 'users#show'
end
