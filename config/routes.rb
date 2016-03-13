Rails.application.routes.draw do

  devise_for :users
  root 'tactics#index'

  get '/sets'    => 'puzzle_sets#index'
  get '/puzzles' => 'puzzle_sets#show'

end
