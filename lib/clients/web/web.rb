require "sinatra"
require "slim"
require "virtus"

require "toodoo"
require "gateways/in_memory_database"

database = InMemoryDatabase.new
user = User.new
user.id = 2
toodoo = Toodoo.new(database)
toodoo.register_user(OpenStruct.new(name: "peter", password: "peter"))

class CreateTodoForm
  include Virtus.model

  attribute :title, String

  def validate!
  end
end

get "/tasks" do
  todos = toodoo.list_my_todos
  slim :tasks, locals: { tasks: todos }
end

post "/tasks" do
  form = CreateTodoForm.new params[:task]
  toodoo.create_todo form
  redirect "/tasks"
end

get "/new_task" do
  slim :new_task
end
