require "entities/task"

class ListUnfinishedTodos
  def initialize(database, user_id, current_user)
    @database = database
    @user_id = user_id
    @current_user = current_user
  end

  def call
    @database.query_todos_for_user UnfinishedTask, @user_id
  end
end
