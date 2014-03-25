require "sinatra"
require "slim"
require "virtus"

require "toodoo"
require "gateways/redis_database"
require "forms"

class TasksPage
  def initialize(tasks, current_user)
    @tasks = tasks
    @current_user = current_user
  end

  class TaskPresenter < Struct.new(:task)
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

url = ENV["REDISTOGO_URL"] || "redis://localhost:6379/1"
REDISDATABASE = RedisDatabase.new url

enable :sessions
set :session_secret, 'secret session token which needs to be replaced in production'

helpers do
  def app
    toodoo = Toodoo.new REDISDATABASE

    begin
      user_id = session[:user_id]
    rescue RecordNotFound
      user_id = session[:user_id] = nil
    end

    if user_id
      toodoo.login_with_user_id user_id
    end

    toodoo
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
  user = app.register_user form
  session[:user_id] = user.id
  redirect "/tasks"
end

get "/login" do
  slim :login, locals: { notice: nil }
end

post "/login" do
  form = LoginForm.new params[:login]
  begin
    user = app.login form
    session[:user_id] = user.id
    redirect "/tasks"
  rescue NotAuthenticated
    slim :login, locals: { notice: "Wrong username or password." }
  end
end

get "/tasks" do
  todos = app.list_my_todos
  tasks_page = TasksPage.new(todos, app.current_user)
  slim :tasks, locals: { tasks_page: tasks_page }
end

post "/tasks" do
  form = CreateTodoForm.new params[:task]
  app.create_todo form
  redirect "/tasks"
end

post "/tasks/:id/delete" do
  app.archive_todo params[:id].to_i
  redirect "/tasks"
end

post "/tasks/:id/done" do
  app.mark_todo_as_done(params[:id].to_i)
  redirect "/tasks"
end

get "/new_task" do
  slim :new_task
end
