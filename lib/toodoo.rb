require "entities/todo"
require "entities/user"
require "use_cases/mark_todo_as_done"
require "use_cases/create_todo"
require "use_cases/errors"
require "use_cases/list_todos"
require "use_cases/list_unfinished_todos"

class Toodoo
  attr_reader :database, :current_user

  def initialize(database, current_user)
    @database = database
    @current_user = current_user
  end

  def archive_todo(todo_id)
    ArchiveTodo.new(database, todo_id, current_user).call
  end

  def create_todo(request)
    CreateTodo.new(database, request, current_user).call
  end

  def mark_todo_as_done(todo_id)
    MarkTodoAsDone.new(database, todo_id, current_user).call
  end

  def list_todos(user_id)
    ListTodos.new(database, user_id, current_user).call
  end

  def list_unfinished_todos
    ListUnfinishedTodos.new(database, current_user).call
  end
end
