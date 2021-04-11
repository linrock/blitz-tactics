class PuzzleReportsController < ApplicationController

  def index
    @puzzle_reports = PuzzleReport.order('id DESC').limit(500)
  end

  def new
    @puzzle_id = params[:puzzle_id]
  end

  def create
    puzzle_report_params = params.require(:puzzle_report).permit(:puzzle_id, :message)
    puzzle_id = puzzle_report_params[:puzzle_id]
    PuzzleReport.create!({
      user_id: current_user.id,
      puzzle_id: puzzle_id,
      message: puzzle_report_params[:message],
    })
    redirect_to "/p/#{puzzle_id}"
  end
end
