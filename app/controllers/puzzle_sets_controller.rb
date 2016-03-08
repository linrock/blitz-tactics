class PuzzleSetsController < ApplicationController

  def index
    @n_sets = 50
  end

  def show
    respond_to do |format|
      format.json { render_lichess }
    end
  end

  private

  def render_v0
    render :json => {
      :format  => 'v0',
      :puzzles => Puzzles.shuffled
    }
  end

  def render_v1
    render :json => {
      :format  => 'v1',
      :puzzles => TacticsLoader.query({
        :n      => Puzzles::SET_SIZE,
        :offset => params[:offset].to_i,
        :turn   => 'w'
      }).shuffle
    }
  end

  def render_lichess
    offset = params[:offset].to_i
    render :json => {
      :format  => 'lichess',
      :puzzles => cached_puzzles[offset..offset + Puzzles::SET_SIZE].shuffle.map(&:data)
    }
  end

  def puzzles
    LichessPuzzle.rating_lt(1600).vote_gt(50).white_to_move
  end

  def cached_puzzles
    cache_key = "puzzles.rating_lt(1600).vote_gt(50).white_to_move:ids"
    puzzle_ids = Rails.cache.read(cache_key)
    return LichessPuzzle.where(id: puzzle_ids) if puzzle_ids.present?
    puzzle_ids = puzzles.pluck(:id)
    Rails.cache.write(cache_key, puzzle_ids)
    LichessPuzzle.where(id: puzzle_ids)
  end

end
