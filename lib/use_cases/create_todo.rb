require "virtus"
require "active_model"
require "entities/task"

class CreateTodo
  def initialize(database, current_user, request)
    @database = database
    @request = request
    @current_user = current_user
  end

  def call
    @request.validate!

    t = Task.new
    t.title = @request.title
    t.user = @current_user

    @database.create t
  end
end
