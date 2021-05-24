class PuzzleSetsController < ApplicationController
  before_action :require_logged_in_user!, only: [:new]

  def index
    # order puzzle sets by when they were last updated
    @puzzle_sets = PuzzleSet.all.order('updated_at DESC').limit(30)
  end

  def show
    @puzzle_set = PuzzleSet.find_by(id: params[:id])
  end

  def puzzles_json
    @puzzle_set = PuzzleSet.find_by(id: params[:id])
    render json: {
      puzzles: @puzzle_set.random_level.as_json
    }
  end

  def new
    @new_puzzle_set = PuzzleSet.new(user_id: current_user.id)
  end

  def create
    if filtered_puzzle_ids.count > 0
      @puzzle_set = current_user.puzzle_sets.create!({
        name: puzzle_set_params[:name],
        description: puzzle_set_params[:description]
      })
      # insert all valid puzzle ids
      LichessV2PuzzlesPuzzleSet.insert_all(filtered_puzzle_ids.map do |puzzle_id|
        {
          puzzle_set_id: @puzzle_set.id,
          lichess_v2_puzzle_id: puzzle_id,
        }
      end)
      redirect_to "/ps/#{@puzzle_set.id}"
    else
      # No valid puzzle IDs found in the payload. Do nothing.
      render status: 400
    end
  end

  def edit
    @puzzle_set = PuzzleSet.find_by(id: params[:id])
  end

  def update
    @puzzle_set = current_user.puzzle_sets.find_by(id: params[:id])
    if @puzzle_set
      ActiveRecord::Base.transaction do
        @puzzle_set.update!({
          name: puzzle_set_params[:name],
          description: puzzle_set_params[:description]
        })
        # delete puzzles that are not in the new puzzle list
        delete_puzzle_ids = @puzzle_set.lichess_v2_puzzle_ids - filtered_puzzle_ids
        LichessV2PuzzlesPuzzleSet.delete_by(
          puzzle_set_id: @puzzle_set.id,
          lichess_v2_puzzle_id: delete_puzzle_ids
        )
        # insert puzzles that aren't already created
        insert_puzzle_ids = filtered_puzzle_ids - @puzzle_set.lichess_v2_puzzle_ids
        if insert_puzzle_ids.length > 0
          LichessV2PuzzlesPuzzleSet.insert_all(insert_puzzle_ids.map do |puzzle_id|
            {
              puzzle_set_id: @puzzle_set.id,
              lichess_v2_puzzle_id: puzzle_id,
            }
          end)
        end
      end
      redirect_to "/ps/#{@puzzle_set.id}"
    else
      # No valid puzzle IDs found in the payload. Do nothing.
      render status: 400
    end
  end

  private

  def puzzle_set_params
    params.require(:puzzle_set).permit(:name, :description, :puzzle_ids)
  end

  # filtered lichess v2 puzzle ids (primary keys) based on actual lichess v2 puzzle ids
  def filtered_puzzle_ids
    lichess_v2_puzzle_ids = puzzle_set_params[:puzzle_ids].
      gsub(/[^a-zA-Z0-9]/, ' ').strip.split(/\s+/).
      select {|puzzle_id| puzzle_id.length == 5 }.uniq.
      take(PuzzleSet::PUZZLE_LIMIT)
    LichessV2Puzzle.where(puzzle_id: lichess_v2_puzzle_ids).pluck(:id)
  end
end
