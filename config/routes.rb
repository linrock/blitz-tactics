Rails.application.routes.draw do

  root 'tactics#index'

  get '/sets'    => 'puzzles#index'
  get '/puzzles' => 'puzzles#show'

end
