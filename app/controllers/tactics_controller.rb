class TacticsController < ApplicationController

  def index
    offset = params[:offset].to_i
    @next_offset = offset + Puzzles::SET_SIZE
    @tactics_set_id = (offset / Puzzles::SET_SIZE) + 1
  end

end
