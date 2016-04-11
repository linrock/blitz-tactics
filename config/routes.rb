Rails.application.routes.draw do

  devise_for :users

  root 'home#index'

  post '/api/levels/:id/attempt'  => 'api/levels#attempt'
  post '/api/levels/:id/complete' => 'api/levels#complete'

  get '/puzzles/search'   => 'puzzles#search'
  get '/puzzles/:id'      => 'puzzles#show'

  get '/about'            => 'static#about'

  get '/levels'           => 'levels#index'
  get '/:level_slug'      => 'levels#show'
  get '/:level_slug/edit' => 'levels#edit'
  put '/:level_slug'      => 'levels#update'

end
