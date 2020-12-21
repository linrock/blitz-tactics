class GameModes::CountdownController < ApplicationController

  def index
    render "game_modes/countdown"
  end

  # json endpoint for fetching puzzles on initial pageload
  def puzzles_json
    countdown_level = CountdownLevel.todays_level
    render json: {
      level_name: countdown_level.name,
      puzzles: countdown_level.puzzles
    }
  end

  # user has completed a countdown level
  def complete
    score = completed_countdown_params[:score].to_i
    if user_signed_in?
      level_name = completed_countdown_params[:level_name]
      if level_name =~ /\A201\d-/
        date = Date.strptime(level_name) rescue nil
        if !date or date > Date.today
          render status: 400, json: {}
          return
        end
      end
      countdown_level = CountdownLevel.find_by(name: level_name)
      current_user.completed_countdown_levels.create!({
        countdown_level_id: countdown_level.id,
        score: score
      })
      render json: {
        score: score,
        best: current_user.completed_countdown_levels.personal_best(countdown_level.id)
      }
    else
      render json: {
        score: score,
        best: score
      }
    end
  end

  private

  def completed_countdown_params
    params.require(:countdown).permit(:level_name, :score)
  end
end
