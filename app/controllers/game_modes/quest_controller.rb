class GameModes::QuestController < ApplicationController

  def puzzles_json
    @puzzles = LichessV2Puzzle.limit(10).map(&:bt_puzzle_data)
    render json: {
      puzzles: @puzzles
    }
  end
end
