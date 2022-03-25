# coding: utf-8
class TasksController < ApplicationController
  before_action :set_task, only: %i[ show edit update destroy ]
  before_action :logged_in_user, only: %i[ new create edit update destroy]

  # GET /tasks or /tasks.json
  def index
    @tasks = Task.all.includes(:user, :state)
  end

  # GET /tasks/1 or /tasks/1.json
  def show
  end

  # GET /tasks/new
  def new
    @task = Task.new
    @users = User.all
    @projects = Project.all
    @tags = Tag.all
    @task_states = TaskState.all

    project_id = params[:project_id]
    unless project_id.nil?
      @task.project ||= Project.find(project_id)
    end
    assigner_name = params[:assigner_name]
    unless assigner_name.nil?
      assigner = User.find_by(name: assigner_name)
      unless assigner.nil?
        @task.assigner_id = assigner.id
      end
    end
    @task.content = params[:content]
    @task.description = params[:description]
  end

  # GET /tasks/1/edit
  def edit
    @users = User.all
    @projects = Project.all
    @tags = Tag.all
    @task_states = TaskState.all
  end

  # POST /tasks or /tasks.json
  def create
    @task = current_user.tasks.build(task_params)
    parse_tag_names(params[:tag_names]) if params[:tag_names]

    if @task.save!
      flash[:success] = "タスクを追加しました"
      create_scrapbox_page
      redirect_to tasks_path
    else
      redirect_back fallback_location: new_task_path
    end
  end

  # PATCH/PUT /tasks/1 or /tasks/1.json
  def update
    parse_tag_names(params[:tag_names]) if params[:tag_names]
    if @task.update(task_params)
      flash[:success] = "タスクを更新しました"
      redirect_to tasks_path
    else
      redirect_back fallback_location: edit_task_path(@task)
    end
  end

  # DELETE /tasks/1 or /tasks/1.json
  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to tasks_url, notice: "タスクを削除しました" }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_task
    @task = Task.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def task_params
    params.require(:task).permit(:assigner_id, :due_at, :content, :description, :project_id, :task_state_id)
  end

  def parse_tag_names(tag_names)
    @task.tags = tag_names.split.map do |tag_name|
      tag = Tag.find_by(name: tag_name)
      tag ? tag : Tag.create(name: tag_name)
    end
  end

  # Replace action-item number into corresponding GitHub issue number.
  # Example:
  #   "-->(name !:0001)" becomes "-->(name nomlab/jay/#10)"
  def cooked_content
    self.read_attribute(:content).split("\n").map do |line|
      line.gsub(/-->\((.+?)!:([0-9]{4})\)/) do |macth|
        assignee, action = $1.strip, $2

        issue = SerialNumber.find_by_id(action.to_i).try(:github_issue)

        issue ? "-->(#{assignee} #{issue}{:data-action-item=\"#{action}\"})" :
          "-->(#{assignee} !:#{action})"
      end
    end.join("\n")
  end

  # Add action-item number with prefix "!:".
  # Example:
  #   "-->(name)" becomes "-->(name !:0001)"
  def add_unique_action_item_marker
    self.content = self.content.split("\n").map do |line|
      line.gsub(/-->\((.+?)(?:!:([0-9]{4}))?\)/) do |macth|
        assignee, action = $1.strip, $2

        action = SerialNumber.create.uid unless action
        "-->(#{assignee} !:#{action})"
      end
    end.join("\n")
  end

  def create_scrapbox_page
    base_url = "https://scrapbox.io/nompedia/"
    serial_number = "AI#{sprintf("%04d", @task.id.to_i)} "
    title = @task.content
    # body = "?body=\#" + @task.assigner.name + "\n"
    scrapbox_url = base_url + serial_number + title + body

    @task["scrapbox_page"] = scrapbox_url
    @task.save!
    
    # redirect_to scrapbox_url, target: :_black, rel: "noopener noreferrer"
  end

end
