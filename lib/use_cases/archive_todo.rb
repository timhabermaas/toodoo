require "use_cases/errors"

class ArchiveTodo
  def initialize(database, todo_id, current_user)
    @database = database
    @todo_id = todo_id
    @current_user = current_user
  end

  def call
    todo = @database.find(Task, @todo_id)

    authorize! todo

    @database.delete todo
  end

  def authorize! todo
    raise Unauthorized.new unless todo.user == @current_user
  end
end
