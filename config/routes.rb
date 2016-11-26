Rails.application.routes.draw do

  devise_for :users

  root 'home#index'

  post '/api/levels/:id/attempt'  => 'api/levels#attempt'
  post '/api/levels/:id/complete' => 'api/levels#complete'


  get '/puzzles/search'   => 'puzzles#search'
  get '/puzzles/:id'      => 'puzzles#show'

  get '/about'            => 'static#about'
  get '/positions'        => 'static#positions'
  get '/position'         => 'static#position'

  resources :positions, :only => [:new, :create, :edit, :update, :show]

  get '/levels'           => 'levels#index'
  get '/scoreboard'       => 'scoreboard#index'

  get '/level-:level_num'      => 'levels#show'
  get '/level-:level_num/edit' => 'levels#edit'
  put '/level-:level_num'      => 'levels#update'

  get '/:username'             => 'users#show'

end
