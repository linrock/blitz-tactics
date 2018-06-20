# Scopes common to old and new lichess puzzle data structures

require 'active_support/concern'

module PuzzleQuery
  extend ActiveSupport::Concern

  included do
    scope :rating_gt, -> (min_rating) do
      where("(data -> 'puzzle' ->> 'rating')::int >= ?", min_rating)
    end

    scope :rating_lt, -> (max_rating) do
      where("(data -> 'puzzle' ->> 'rating')::int <= ?", max_rating)
    end

    scope :attempts_gt, -> (n_attempts) do
      where("(data -> 'puzzle' ->> 'attempts')::int > ?", n_attempts)
    end

    scope :vote_gt, -> (votes) do
      where("(data -> 'puzzle' ->> 'vote')::int > ?", votes)
    end

    scope :white_to_move, -> do
      where("data -> 'puzzle' ->> 'color' = 'white'")
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
  end
end
