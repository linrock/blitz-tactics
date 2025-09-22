Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }

  root 'pages#home'
  get '/world-1' => 'pages#world1'
  get '/world-2' => 'pages#world2'
  get '/world-3' => 'pages#world3'
  get '/world-4' => 'pages#world4'
  get '/world-5' => 'pages#world5'
  get '/world-6' => 'pages#world6'
  get '/puzzle-player' => 'pages#puzzle_player'
  
  # Puzzle tracking
  post '/solved-puzzles' => 'solved_puzzles#create'
  get '/quest/puzzles' => 'game_modes/quest#puzzles_json'
  get '/quest/edit' => 'game_modes/quest#edit'
  get '/quest/worlds/new' => 'game_modes/quest#new_quest_world'
  post '/quest/worlds' => 'game_modes/quest#create_quest_world'
  get '/quest/worlds/:id/edit' => 'game_modes/quest#edit_quest_world'
  patch '/quest/worlds/:id' => 'game_modes/quest#update_quest_world'
  put '/quest/worlds/:id' => 'game_modes/quest#update_quest_world'
  get '/quest/worlds/:quest_world_id/levels/new' => 'game_modes/quest#new_quest_level'
  post '/quest/worlds/:quest_world_id/levels' => 'game_modes/quest#create_quest_level'
  get '/quest/levels/:id/edit' => 'game_modes/quest#edit_quest_level'
  put '/quest/levels/:id' => 'game_modes/quest#update_quest_level'
  patch '/quest/levels/:id' => 'game_modes/quest#update_quest_level'
  delete '/quest/levels/:id' => 'game_modes/quest#destroy_quest_level'
  get '/quest/levels/:id' => 'game_modes/quest#show'
  post '/quest/levels/:id/complete' => 'game_modes/quest#complete'
  get '/quest/:world_id/:world_level_id' => 'game_modes/quest#play_quest_level'

  # infinity mode
  get '/infinity'                => 'game_modes/infinity#index'
  get '/infinity/puzzles.json'   => 'game_modes/infinity#puzzles_json'
  get '/infinity/puzzles'        => 'game_modes/infinity#puzzles'
  post '/infinity/puzzles'       => 'game_modes/infinity#puzzle_solved'
  get '/infinity/recent_puzzle_item' => 'game_modes/infinity#recent_puzzle_item'

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
  post '/haste/track-puzzle'     => 'game_modes/haste#track_puzzle'

  # mate-in-one mode
  get '/mate-in-one'             => 'game_modes/mate_in_one#index'
  get '/mate-in-one/puzzles'     => 'game_modes/mate_in_one#puzzles'
  post '/mate-in-one'            => 'game_modes/mate_in_one#complete'

  # rook-endgames mode
  get '/rook-endgames'           => 'game_modes/rook_endgames#index'
  get '/rook-endgames/puzzles'   => 'game_modes/rook_endgames#puzzles'
  post '/rook-endgames'          => 'game_modes/rook_endgames#complete'

  # openings mode
  get '/openings'                => 'game_modes/openings#index'
  get '/openings/puzzles'        => 'game_modes/openings#puzzles'
  post '/openings'               => 'game_modes/openings#complete'

  # threes mode
  get '/three'                  => 'game_modes/three#index'
  get '/three/puzzles'          => 'game_modes/three#puzzles'
  post '/three'                 => 'game_modes/three#complete'
  post '/three/track-puzzle'    => 'game_modes/three#track_puzzle'

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
  get '/achievements'            => 'achievements#index'
  get '/about'                   => 'pages#about'
  get '/puzzle-themes'           => 'pages#puzzle_themes'
  
  # admin page
  get '/admin'                   => 'admin#index'
  get '/admin/feature-flags'     => 'admin#feature_flags'
  post '/admin/feature-flags'    => 'admin#create_feature_flag'
  patch '/admin/feature-flags/:id' => 'admin#update_feature_flag'
  put '/admin/feature-flags/:id' => 'admin#update_feature_flag'
  post '/admin/feature-flags/:id/toggle' => 'admin#toggle_feature_flag'
  delete '/admin/feature-flags/:id' => 'admin#destroy_feature_flag'

  # puzzle pages
  get '/puzzles'                 => 'puzzles#index'
  get '/puzzles/:puzzle_ids'     => 'puzzles#index'
  get '/p/:puzzle_id'            => 'puzzles#show'
  get '/p/:puzzle_id/solution'   => 'puzzles#solution'
  get '/p/:puzzle_id/edit'       => 'puzzles#edit'
  put '/p/:puzzle_id'            => 'puzzles#update'

  # puzzle reports
  get '/puzzle_reports'          => 'puzzle_reports#index'
  post '/puzzle_reports'         => 'puzzle_reports#create'

  # puzzle sets
  get '/puzzle-sets'             => 'puzzle_sets#index'
  get '/puzzle-sets/new'         => 'puzzle_sets#new'
  post '/puzzle-sets'            => 'puzzle_sets#create'
  get '/ps/:id/edit'             => 'puzzle_sets#edit'
  get '/ps/:id'                  => 'puzzle_sets#show'
  get '/ps/:id/puzzles.json'     => 'puzzle_sets#puzzles_json'
  put '/ps/:id'                  => 'puzzle_sets#update'

  # position pages
  get '/positions'               => 'pages#positions'
  get '/positions/:id'           => 'pages#position'
  get '/position'                => 'pages#position'
  get '/pawn-endgames'           => 'pages#pawn_endgames'
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
  
  # preferences
  get '/preferences'             => 'users#preferences'
  delete '/account'              => 'users#destroy'

  patch '/settings'              => 'user_settings#update'

  # user routes
  put '/users/me'                => 'users#update'
  get '/:username'               => 'users#show'
end
