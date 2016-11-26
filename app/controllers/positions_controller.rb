class PositionsController < ApplicationController
  before_filter :require_logged_in_user!

  def new
    @position = Position.new
  end

  def show
    @position = Position.find(params[:id])
  end

  def edit
    @position = current_user.positions.find(params[:id])
    render :new
  end

  def create
    @position = current_user.positions.create!(
      params.require(:position).permit(
        :fen, :goal, :name, :description, :configuration
      )
    )
    redirect_to edit_position_url(@position.id)
  end

end
