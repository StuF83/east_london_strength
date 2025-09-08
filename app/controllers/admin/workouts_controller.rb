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
    @workout = Workout.new(workout_params)

    if @workout.save
      redirect_to admin_workout_path(@workout), notice: "Workout created successfully."
    else
      render :new, status: :unprocessable_entity
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

  private

  def set_workout
    @workout = Workout.find(params[:id])
  end

  def workout_params
    params.require(:workout).permit(:date, :title, :content, :tags, :is_fallback)
  end
end
