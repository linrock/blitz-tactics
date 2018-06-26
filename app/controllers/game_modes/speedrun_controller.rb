# speedrun mode puzzles

class GameModes::SpeedrunController < ApplicationController

  def index
    render "game_modes/speedrun"
  end

  # json endpoint for fetching puzzles
  def puzzles
    render json: {
      puzzles: speedrun_level.speedrun_puzzles
    }
  end

  # user has completed a speedrun
  def complete
    if user_signed_in?
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

  def speedrun_level
    if params[:name]
      SpeedrunLevel.find_by(name: params[:name])
    else
      SpeedrunLevel.first_level
    end
  end

  def completed_speedrun_level
    @completed_speedrun_level ||= SpeedrunLevel.find_by(
      name: completed_speedrun_params[:level_name]
    )
  end

  def completed_speedrun_params
    params.require(:speedrun).permit(:elapsed_time_ms, :level_name)
  end
end
