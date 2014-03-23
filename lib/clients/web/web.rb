require "sinatra"
require "slim"
require "virtus"

require "toodoo"
require "gateways/in_memory_database"
require "forms"

database = InMemoryDatabase.new
user = User.new
user.id = 2
toodoo = Toodoo.new(database)

get "/register" do
  slim :register
end

post "/register" do
  form = RegisterUserForm.new params[:register]
  toodoo.register_user form
  redirect "/tasks"
end

get "/login" do
  slim :login
end

post "/login" do
  form = LoginForm.new params[:login]
  toodoo.login form
  redirect "/tasks"
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
