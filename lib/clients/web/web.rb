require "sinatra"
require "slim"
require "virtus"

require "toodoo"
require "gateways/redis_database"
require "gateways/console_print_mailer"
require "gateways/sendgrid_mailer"
require "forms"

class TaskPage < Struct.new(:task)
  def task_title
    task_presenter.title
  end

  def comments
    task.comments.map do |c|
      CommentPresenter.new(c)
    end
  end

  def comments_post_path
    "/tasks/#{task.id}/comments"
  end

  private
    def task_presenter
      @task_presenter ||= TaskPresenter.new(task)
    end
end

class CommentPresenter < Struct.new(:comment)
  def author_name
    comment.author.name
  end

  def content
    comment.content
  end
end

class TaskPresenter < Struct.new(:task)
  def title
    task.title
  end

  def marked_symbol
    task.done? ? "[x]" : "[ ]"
  end

  def comments_count
    "#{task.comment_size} Comments"
  end

  def show_path
    "/tasks/#{task.id}"
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

class TasksPage
  def initialize(tasks, current_user)
    @tasks = tasks
    @current_user = current_user
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
MAILER = if ENV["SENDGRID_PASSWORD"] && ENV["SENDGRID_PASSWORD"]
  SendgridMailer.new ENV["SENDGRID_USERNAME"], ENV["SENDGRID_PASSWORD"]
else
  ConsolePrintMailer.new
end

enable :sessions
set :session_secret, 'secret session token which needs to be replaced in production'

helpers do
  def app
    toodoo = Toodoo.new REDISDATABASE, MAILER

    user_id = session[:user_id]

    if user_id
      begin
        toodoo.login_with_user_id user_id
      rescue RecordNotFound
        session[:user_id] = nil
      end
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

get "/tasks/:id" do
  task = app.show_task params[:id].to_i
  page = TaskPage.new(task)
  slim :task, locals: { page: page }
end

post "/tasks" do
  form = CreateTodoForm.new params[:task]
  begin
    app.create_todo form
    redirect "/tasks"
  rescue ValidationError => e
    slim :new_task, locals: { task: form }
  end
end

post "/tasks/:id/delete" do
  app.archive_todo params[:id].to_i
  redirect "/tasks"
end

post "/tasks/:id/done" do
  app.mark_todo_as_done(params[:id].to_i)
  redirect "/tasks"
end

post "/tasks/:task_id/comments" do
  form = OpenStruct.new(content: params[:comment][:content])
  app.comment_on_task(params[:task_id].to_i, form)
  redirect "/tasks/#{params[:task_id]}"
end

get "/new_task" do
  form = CreateTodoForm.new
  slim :new_task, locals: { task: form }
end
