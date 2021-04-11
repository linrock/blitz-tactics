# data keys - id (lichess puzzle id), fen, initialMove, lines

require 'active_support/concern'

module PuzzleRecord
  extend ActiveSupport::Concern

  DATA_KEYS = %w( id fen initialMove lines )

  included do
    before_validation :calculate_and_set_puzzle_hash
    validates :data, presence: true
    validate :check_data_fields

    default_scope { order('id ASC') }

    def fen
      data["fen"]
    end

    def initial_move
      data["initialMove"] # san, uci
    end

    def initial_move_uci
      initial_move["uci"]
    end

    def initial_move_san
      initial_move["san"]
    end

    def lines
      data["lines"]
    end

    def as_json(options = {})
      if options[:lichess_puzzle_id]
        data.merge(id: data["id"])
      else
        data.merge(id: id)
      end
    end

    # a way to uniquely-identify puzzles based on the moves in the puzzle
    def calculate_puzzle_hash
      puzzle_data = data.slice("fen", "initialMove", "lines")
      Digest::MD5.hexdigest puzzle_data.to_json
    end

    private

    def check_data_fields
      unless DATA_KEYS.all? {|key| data[key].present? }
        errors.add(:data, "has blank data values")
      end
      unless initial_move["uci"].present? and initial_move["san"].present?
        errors.add(:data, "initial move is invalid")
      end
      unless fen.split(/ /).length == 6
        errors.add(:data, "fen is invalid")
      end
      unless lines.to_json.include? "win"
        errors.add(:data, "lines has no way to win")
      end
    end

    def calculate_and_set_puzzle_hash
      self.puzzle_hash = calculate_puzzle_hash
    end
  end
end
