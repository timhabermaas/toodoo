require "entities/todo"

class ListUnfinishedTodos
  def initialize(database, current_user)
    @database = database
    @current_user = current_user
  end

  def call
    yield @database.query_todo_unfinished_for_user(Todo, @current_user)
  end
end
