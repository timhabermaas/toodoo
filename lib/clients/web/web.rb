require "sinatra"
require "slim"
require "virtus"

require "toodoo"
require "gateways/redis_database"
require "forms"

url = "redis://localhost:6379/1"
database = RedisDatabase.new url
toodoo = Toodoo.new database

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
  slim :tasks, locals: { tasks: todos, current_user: toodoo.current_user }
end

post "/tasks" do
  form = CreateTodoForm.new params[:task]
  toodoo.create_todo form
  redirect "/tasks"
end

get "/new_task" do
  slim :new_task
end
