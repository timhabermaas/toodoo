require "sinatra"
require "slim"
require "virtus"

require "toodoo"
require "gateways/redis_database"
require "forms"

url = ENV["REDISTOGO_URL"] || "redis://localhost:6379/1"
database = RedisDatabase.new url
toodoo = Toodoo.new database

class TasksPage
  def initialize(tasks, current_user)
    @tasks = tasks
    @current_user = current_user
  end

  class TaskPresenter < Struct.new(:task)
    # TODO remove
    def id
      task.id
    end

    def title
      task.title
    end

    def marked_symbol
      task.done? ? "[x]" : "[ ]"
    end

    def mark_as_done_path
      "/tasks/#{task.id}/done"
    end

    def delete_path
      "/tasks/#{task.id}/delete"
    end

    def show_mark_button?
      !task.done?
    end
  end

  def tasks
    @tasks.map { |t| TaskPresenter.new(t) }
  end

  def logged_in?
    !current_user.nil?
  end

  def current_user
    @current_user
  end
end

get "/" do
  redirect "/login"
end

get "/register" do
  slim :register
end

post "/register" do
  form = RegisterUserForm.new params[:register]
  toodoo.register_user form
  redirect "/tasks"
end

get "/login" do
  slim :login, locals: { notice: nil }
end

post "/login" do
  form = LoginForm.new params[:login]
  begin
    toodoo.login form
    redirect "/tasks"
  rescue NotAuthenticated
    slim :login, locals: { notice: "Wrong username or password." }
  end
end

get "/tasks" do
  todos = toodoo.list_my_todos
  tasks_page = TasksPage.new(todos, toodoo.current_user)
  slim :tasks, locals: { tasks_page: tasks_page }
end

post "/tasks" do
  form = CreateTodoForm.new params[:task]
  toodoo.create_todo form
  redirect "/tasks"
end

post "/tasks/:id/delete" do
  toodoo.archive_todo params[:id].to_i
  redirect "/tasks"
end

post "/tasks/:id/done" do
  toodoo.mark_todo_as_done(params[:id].to_i)
  redirect "/tasks"
end

get "/new_task" do
  slim :new_task
end
