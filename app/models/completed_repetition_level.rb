class CompletedRepetitionLevel < ActiveRecord::Base
  belongs_to :user
  belongs_to :repetition_level
end
