Rails.application.routes.draw do

  devise_for :users

  root 'tactics#index'

  get '/puzzles'     => 'puzzle_sets#show'

  post '/api/levels/:id/attempt'  => 'api/levels#attempt'
  post '/api/levels/:id/complete' => 'api/levels#complete'

  get '/levels'           => 'levels#index'
  get '/:level_slug'      => 'levels#show'
  get '/:level_slug/edit' => 'levels#edit'

  get '/puzzles/:id'      => 'puzzles#show'

end
