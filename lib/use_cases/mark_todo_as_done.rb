require "entities/todo"
require "use_cases/errors"

class MarkTodoAsDone
  def initialize(database, todo_id, current_user)
    @database = database
    @todo_id = todo_id
    @current_user = current_user
  end

  def call
    todo = @database.find Todo, @todo_id
    authorize! todo

    todo.done!
    @database.update todo
  end

  private
    def authorize!(todo)
      raise Unauthorized unless todo.user == @current_user
    end
end
