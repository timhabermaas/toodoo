require "entities/todo"

class ListUnfinishedTodos
  def initialize(database, user_id, current_user)
    @database = database
    @user_id = user_id
    @current_user = current_user
  end

  def call
    @database.query_todo_unfinished_for_user Todo, @user_id
  end
end
