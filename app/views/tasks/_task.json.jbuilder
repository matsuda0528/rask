json.extract! task, :id, :registerdate, :duedate, :task, :user_id, :created_at, :updated_at
json.url task_url(task, format: :json)
