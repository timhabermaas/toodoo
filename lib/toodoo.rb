require "entities"
require "use_cases/mark_todo_as_done"
require "use_cases/create_todo"
require "use_cases/errors"
require "use_cases/list_todos"
require "use_cases/list_unfinished_todos"
require "use_cases/register_user"
require "use_cases/archive_todo"
require "use_cases/show_task"
require "use_cases/comment_on_task"
require "use_cases/login"

class Toodoo
  attr_reader :database, :mailer, :current_user

  def initialize(database, mailer)
    @database = database
    @mailer = mailer
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
    user = RegisterUser.new(database, mailer, current_user, request).call
    @current_user = user
  end

  def login(request)
    user = Login.new(database, current_user, request).call
    @current_user = user
  end

  def login_with_user_id(user_id)
    @current_user = database.find User, user_id
  end

  def mark_todo_as_done(todo_id)
    MarkTodoAsDone.new(database, current_user, todo_id).call
  end

  def comment_on_task(task_id, request)
    CommentOnTask.new(database, current_user, task_id, request).call
  end

  def list_todos(user_id)
    ListTodos.new(database, current_user, user_id).call
  end

  def list_my_todos
    list_todos current_user.id
  end

  def show_task(task_id)
    ShowTask.new(database, current_user, task_id).call
  end

  def list_unfinished_todos(user_id)
    ListUnfinishedTodos.new(database, current_user, user_id).call
  end

  def list_my_unfinished_todos
    list_unfinished_todos current_user.id
  end
end
