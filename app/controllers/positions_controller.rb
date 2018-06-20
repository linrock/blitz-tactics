class PositionsController < ApplicationController
  before_action :require_logged_in_user!, :except => [ :show ]

  def show
    @position = Position.find(params[:id])
  end

  def create
    @position = current_user.positions.create!(
      params.require(:position).permit(
        :fen, :goal, :name, :description, :configuration
      )
    )
    redirect_to "/positions/#{@position.id}"
  end
end
