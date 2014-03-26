require "use_cases/errors"

class ShowTask < Struct.new(:database, :current_user, :task_id)
  def call
    task = database.find_graph Task, task_id

    authorize! task

    task
  end

  def authorize! task
    raise Unauthorized.new unless task.user.id == current_user.id
  end
end
