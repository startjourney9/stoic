  class ExercisesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_exercise, only: [:edit, :update, :destroy]

  #Load CanCan roles for Controller
  load_and_authorize_resource

  # GET /exercises
  # GET /exercises.json
  def index
    @exercises = Exercise.where(user_id:current_user.id)
    @global_exercises = Exercise.where(global:true).order(:updated_at)
  end

  # GET /exercises/1
  # GET /exercises/1.json
  def show
    @exercise = Exercise.find(params[:id])
    @rehearsals = @exercise.rehearsals_for_user(current_user)
    all_tags = @exercise.tags
      binding.pry
    unless all_tags.nil? || all_tags.empty?
      tagged_doctrines = Doctrine.tagged_with(all_tags.first.name)
      all_tags.each do |tag|
        tagged_doctrines << Doctrine.tagged_with(tag.name)
      end
      @published_doctrines = tagged_doctrines.where(publish:true)
    end
  end

  # GET /exercises/new
  def new
    @exercise = Exercise.new
    3.times do
      e_question = @exercise.e_questions.build
      e_question.e_answers.build
    end
  end

  # GET /exercises/1/edit
  def edit
  end

  # POST /exercises
  # POST /exercises.json
  def create
    @exercise = Exercise.new(exercise_params)
    @exercise.user_id = current_user.id
    respond_to do |format|
      if @exercise.save
        format.html { redirect_to @exercise, notice: 'Exercise was successfully created.' }
        format.json { render action: 'show', status: :created, location: @exercise }
      else
        format.html { render action: 'new' }
        format.json { render json: @exercise.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /exercises/1
  # PATCH/PUT /exercises/1.json
  def update
    respond_to do |format|
      if @exercise.update(exercise_params)
        format.html { redirect_to @exercise, notice: 'Exercise was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @exercise.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /exercises/1
  # DELETE /exercises/1.json
  def destroy
    @exercise.destroy
    respond_to do |format|
      format.html { redirect_to exercises_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_exercise
      @exercise = Exercise.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def exercise_params
      params.require(:exercise).permit(:_destroy, :title, :general_description, :category, :global, :tag_list, e_questions_attributes: [:id, :question, :_destroy])
    end
end
