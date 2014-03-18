require "entities/task"
require "use_cases/errors"

class MarkTodoAsDone
  def initialize(database, current_user, todo_id)
    @database = database
    @todo_id = todo_id
    @current_user = current_user
  end

  def call
    todo = @database.find UnfinishedTask, @todo_id
    authorize! todo

    @database.update todo.done
  end

  private
    def authorize!(todo)
      raise Unauthorized unless todo.user == @current_user
    end
end
