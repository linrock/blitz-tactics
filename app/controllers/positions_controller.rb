class PositionsController < ApplicationController
  def show
    @position = Position.find(params[:id])
  end
end
