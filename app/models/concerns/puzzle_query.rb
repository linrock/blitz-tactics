# Scopes common to old and new lichess puzzle data structures

require 'active_support/concern'

module PuzzleQuery
  extend ActiveSupport::Concern

  included do
    scope :rating_range, -> (min, max) do
      rating_gte(min).rating_lte(max)
    end

    scope :rating_gte, -> (min_rating) do
      where("(metadata ->> 'rating')::int >= ?", min_rating)
    end

    scope :rating_lte, -> (min_rating) do
      where("(metadata ->> 'rating')::int <= ?", min_rating)
    end

    scope :attempts_gt, -> (n_attempts) do
      where("(metadata ->> 'attempts')::int > ?", n_attempts)
    end

    scope :vote_gt, -> (votes) do
      where("(metadata ->> 'vote')::int > ?", votes)
    end

    scope :white_to_move, -> do
      where("(metadata ->> 'color') = 'white'")
    end

    scope :black_to_move, -> do
      where("(metadata ->> 'color') = 'black'")
    end

    scope :ascending_rating, -> do
      order('rating ASC')
    end

    scope :enabled, -> do
      where("(metadata -> 'puzzle' ->> 'enabled')::bool")
    end

    scope :old_batch, -> do
      where("(metadata -> 'puzzle' ->> 'id')::int <= 60120")
    end

    scope :new_batch, -> do
      where("(metadata -> 'puzzle' ->> 'id')::int > 60120")
    end

    # Puzzle IDs below this have been deleted from lichess.org
    # TODO set a max id on this if adding more puzzles
    scope :new_not_deleted, -> do
      where("id >= 61053 AND id <= 125272")
    end

    def self.n_pieces_query
      "char_length(
         regexp_replace(
           split_part(data -> 'puzzle' ->> 'fen', ' ', 1),
           '[^a-zA-Z]', '', 'g'
         )
       )"
    end

    scope :n_pieces_eq, -> (n) do
      where("#{n_pieces_query} = ?", n)
    end

    scope :n_pieces_lt, -> (n) do
      where("#{n_pieces_query} < ?", n)
    end

    scope :n_pieces_gt, -> (n) do
      where("#{n_pieces_query} > ?", n)
    end

    scope :no_retry, -> do
      where(%(
        (puzzle_data ->> 'lines')::TEXT NOT LIKE '%"retry"%'
      ))
    end
  end
end
