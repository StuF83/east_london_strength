class WorkoutsController < ApplicationController
  def today
    @today = Date.current
    @yesterday = @today - 1.day
    @tomorrow = @today + 1.day

    @workout_today = find_or_fallback(@today)
    @workout_yesterday = find_or_fallback(@yesterday)
    @workout_tomorrow = find_or_fallback(@tomorrow)
  end

  private

  def find_or_fallback(date)
    workout = Workout.find_by(date: date)

    workout ||= Workout.fallbacks.sample

    workout
  end
end
