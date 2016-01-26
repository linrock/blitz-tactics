Rails.application.routes.draw do

  root 'tactics#index'

  get '/puzzles' => 'puzzles#index'

end
