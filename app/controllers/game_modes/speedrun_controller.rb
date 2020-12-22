class GameModes::SpeedrunController < ApplicationController

  def index
    render "game_modes/speedrun"
  end

  # json endpoint for fetching puzzles on initial pageload
  def puzzles_json
    speedrun_level = SpeedrunLevel.todays_level
    render json: {
      level_name: speedrun_level.name,
      puzzles: speedrun_level.puzzles
    }
  end

  # page for viewing the list of puzzles in the game mode
  def puzzles
    speedrun_level = SpeedrunLevel.todays_level
    lichess_puzzle_ids = speedrun_level.puzzles.map { |p| p["id"] }
    @puzzles = Puzzle.find_by_sorted(lichess_puzzle_ids)
  end

  # user has completed a speedrun
  def complete
    if user_signed_in?
      level_name = completed_speedrun_params[:level_name]
      if level_name =~ /\A201\d-/
        date = Date.strptime(level_name) rescue nil
        if !date or date > Date.today
          render status: 400, json: {}
          return
        end
      end
      completed_speedrun_level = SpeedrunLevel.find_by(name: level_name)
      current_user.completed_speedruns.create!({
        speedrun_level_id: completed_speedrun_level.id,
        elapsed_time_ms: completed_speedrun_params[:elapsed_time_ms].to_i
      })
      render json: {
        best: current_user.completed_speedruns.personal_best(
          completed_speedrun_level.id
        )
      }
    else
      render json: {}
    end
  end

  private

  def completed_speedrun_params
    params.require(:speedrun).permit(:elapsed_time_ms, :level_name)
  end
end
