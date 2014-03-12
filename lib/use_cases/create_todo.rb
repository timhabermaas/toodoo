require "virtus"
require "active_model"

ValidationError = Class.new StandardError

class CreateTodo
  def initialize(database, request, current_user)
    @database = database
    @request = request
    @current_user = current_user
  end

  def call
    @request.validate!

    t = Todo.new
    t.title = @request.title
    t.body = @request.body
    t.user = @current_user

    @database.create t
  end
end

class CreateTodoForm
  include Virtus.model
  include ActiveModel::Validations

  attribute :title, String
  attribute :body, String
end
