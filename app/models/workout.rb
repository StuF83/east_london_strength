class Workout < ApplicationRecord
  has_rich_text :content

  validates :date, presence: true, uniqueness: true
  validates :content, presence: true
  validates :is_fallback, inclusion: { in: [ true, false ] }

  scope :fallbacks, -> { where(is_fallback: true) }
  scope :recent, -> { order(date: :desc) }
end
