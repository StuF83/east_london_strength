class PagesController < ApplicationController
  def home
    @today_workout = Workout.find_or_fallback(Date.current)
  end

  def about
  end

  def train_with_me
  end

  def contact
  end

  def testimonials
  end
end
