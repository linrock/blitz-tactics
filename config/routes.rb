Rails.application.routes.draw do

  root 'tactics#index'

  get '/sets'    => 'puzzle_sets#index'
  get '/puzzles' => 'puzzle_sets#show'

end
