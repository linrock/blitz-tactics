class PositionsController < ApplicationController
  before_action :require_logged_in_user!, :except => [ :show ]

  def show
    @position = Position.find(params[:id])
  end

  def new
    @position = Position.new
  end

  def create
    @position = current_user.positions.create!(
      params.require(:position).permit(
        :fen, :goal, :name, :description, :configuration
      )
    )
    redirect_to "/positions/#{@position.id}"
  end

  def edit
    @position = current_user.positions.find(params[:id])
    render :new
  end

  def update
    @position = current_user.positions.find(params[:id])
    @position.update_attributes!(
      params.require(:position).permit(
        :fen, :goal, :name, :description, :configuration
      )
    )
    redirect_to "/positions/#{@position.id}"
  end

end
