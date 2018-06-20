# deprecated custom positions for training

class Position < ActiveRecord::Base
  belongs_to :user

  before_validation :sanitize_fen
  validates :fen, presence: true
  validate :validate_fen_format

  def name_or_id
    name || "Position #{id}"
  end

  def belongs_to?(user)
    user&.id == user_id
  end

  private

  def sanitize_fen
    if self.fen.split(" ").length == 4
      self.fen = self.fen + " 0 1"
    end
  end

  def validate_fen_format
    if fen.split(" ").length != 6
      errors.add(:fen, "must have 6 components")
    end
    if fen.length > 90
      errors.add(:fen, "is invalid")
    end
  end
end
