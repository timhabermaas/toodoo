require "entities"
require "use_cases/mark_todo_as_done"
require "use_cases/create_todo"
require "use_cases/errors"
require "use_cases/list_todos"
require "use_cases/list_unfinished_todos"
require "use_cases/register_user"
require "use_cases/login"

class Toodoo
  attr_reader :database, :current_user

  def initialize(database)
    @database = database
  end

  def logged_in?
    current_user != nil
  end

  def archive_todo(todo_id)
    ArchiveTodo.new(database, current_user, todo_id).call
  end

  def create_todo(request)
    CreateTodo.new(database, current_user, request).call
  end

  def register_user(request)
    user = RegisterUser.new(database, current_user, request).call
    @current_user = user
  end

  def login(request)
    user = Login.new(database, current_user, request).call
    @current_user = user
  end

  def mark_todo_as_done(todo_id)
    MarkTodoAsDone.new(database, current_user, todo_id).call
  end

  def list_todos(user_id)
    ListTodos.new(database, current_user, user_id).call
  end

  def list_my_todos
    list_todos current_user.id
  end

  def list_unfinished_todos(user_id)
    ListUnfinishedTodos.new(database, current_user, user_id).call
  end

  def list_my_unfinished_todos
    list_unfinished_todos current_user.id
  end
end
