# id, fen, initialMove, lines
# data.id = lichess puzzle id

require 'active_support/concern'

module PuzzleRecord
  extend ActiveSupport::Concern

  DATA_KEYS = %w( id fen initialMove lines )

  included do

    before_validation :calculate_and_set_puzzle_hash
    validates :data, presence: true
    validates :puzzle_hash, uniqueness: true
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

    def lines
      data["lines"]
    end

    def as_json(options = {})
      data.merge(id: id)
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
      puzzle_data = data.slice("fen", "initialMove", "lines")
      self.puzzle_hash = Digest::MD5.hexdigest puzzle_data.to_json
    end
  end
end
