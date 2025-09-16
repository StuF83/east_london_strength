# app/controllers/admin/workouts_controller.rb

class Admin::WorkoutsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin
  before_action :set_workout, only: [ :show, :edit, :update, :destroy ]

  def index
    @workouts = Workout.recent.limit(50)
  end

  def show
  end

  def new
    @workout = Workout.new(date: Date.current)
  end

  def create
    if params[:source_workout_id].present?
      # Handle copying existing workout
      handle_workout_copy
    else
      # Handle regular workout creation
      @workout = Workout.new(workout_params)
      if @workout.save
        redirect_to admin_workout_path(@workout), notice: "Workout created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def edit
  end

  def update
    if @workout.update(workout_params)
      redirect_to admin_workout_path(@workout), notice: "Workout updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @workout.destroy
    redirect_to admin_workouts_path, notice: "Workout deleted."
  end

  # AJAX endpoint for copy feature
  def existing_dates
    # Calculate date range: previous month + current month + next 3 months
    start_date = 1.month.ago.beginning_of_month
    end_date = 3.months.from_now.end_of_month

    # Efficiently fetch only the dates within our range
    existing_dates = Workout.where(date: start_date..end_date)
                           .pluck(:date)
                           .map(&:iso8601)

    render json: {
      existing_dates: existing_dates,
      date_range: {
        start: start_date.iso8601,
        end: end_date.iso8601
      }
    }
  end

  private

  def handle_workout_copy
    source_workout = Workout.find(params[:source_workout_id])
    target_date = Date.parse(params[:date])

    # Double-check that target date doesn't already have a workout
    if Workout.exists?(date: target_date)
      redirect_to admin_workout_path(source_workout),
                 alert: "A workout already exists for #{target_date.strftime('%B %d, %Y')}."
      return
    end

    # Create the copy
    @workout = source_workout.dup
    @workout.date = target_date
    @workout.title = "#{source_workout.title} (Copy)" if source_workout.title.present?

    # Handle Action Text content copying
    if source_workout.content.present?
      @workout.content = source_workout.content.body
    end

    if @workout.save
      redirect_to edit_admin_workout_path(@workout),
                 notice: "Workout copied to #{target_date.strftime('%B %d, %Y')}. You can now customize the copy."
    else
      redirect_to admin_workout_path(source_workout),
                 alert: "Failed to copy workout: #{@workout.errors.full_messages.join(', ')}"
    end
  end

  def set_workout
    @workout = Workout.find(params[:id])
  end

  def workout_params
    params.require(:workout).permit(:date, :title, :content, :tags, :is_fallback)
  end

  def ensure_admin
    redirect_to root_path unless current_user.admin?
  end
end
