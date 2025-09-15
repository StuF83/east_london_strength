class WorkoutsController < ApplicationController
  def index
    @today = Date.current
    @yesterday = @today - 1.day
    @tomorrow = @today + 1.day

    @current_date = @today
    @current_workout = Workout.find_or_fallback(@today)
  end

  def show
    # Show workout for yesterday, today, or tomorrow only
    # Reject any other date attempts
    @today = Date.current
    allowed_dates = [ @today - 1.day, @today, @today + 1.day ]

    if params[:date].present?
      begin
        requested_date = Date.parse(params[:date])
      rescue Date::Error
        redirect_to resources_daily_workout_path, alert: "Invalid date"
        return
      end

      unless allowed_dates.include?(requested_date)
        redirect_to resources_daily_workout_path, alert: "Only yesterday, today, and tomorrow workouts are available"
        return
      end

      @current_date = requested_date
    else
      @current_date = @today
    end

    @current_workout = find_or_fallback(@current_date)

    # For Turbo Frame requests, render just the workout content
    if request.headers["Turbo-Frame"]
      render layout: false
    end
  end

  def today
    # Helper method to get just today's workout (for homepage preview)
    @workout = find_or_fallback(Date.current)
    @date = Date.current
  end

  private

  def set_date_and_workout
    if params[:date].present?
      begin
        @date = Date.parse(params[:date])
      rescue Date::Error
        redirect_to resources_daily_workout_path, alert: "Invalid date"
        return
      end
    else
      @date = Date.current
    end

    @workout = find_or_fallback(@date)
  end
end
