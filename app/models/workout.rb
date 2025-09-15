class Workout < ApplicationRecord
  has_rich_text :content

  validates :date, presence: true, uniqueness: true
  validates :content, presence: true
  validates :is_fallback, inclusion: { in: [ true, false ] }

  scope :fallbacks, -> { where(is_fallback: true) }
  scope :recent, -> { order(date: :desc) }

  def self.find_or_fallback(date)
    # Try to find workout for the specific date (non-fallback)
    workout = find_by(date: date, is_fallback: false)

    # If no workout for that date, get a random fallback workout
    if workout.nil?
      fallback_workout = fallbacks.sample

      # Create a temporary workout object with the requested date but fallback content
      if fallback_workout
        workout = new(
          date: date,
          title: fallback_workout.title,
          content: fallback_workout.content,
          tags: fallback_workout.tags,
          is_fallback: true
        )
        workout.id = fallback_workout.id # Keep original ID for any references
      end
    end

    workout
  end
end
