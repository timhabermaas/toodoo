require "entities/task"
require "use_cases/errors"

class ListUnfinishedTodos
  def initialize(database, current_user, user_id)
    @database = database
    @user_id = user_id
    @current_user = current_user
  end

  def call
    authorize!

    @database.query_unfinished_todos_for_user @user_id
  end

  private
    def authorize!
      raise Unauthorized unless @current_user && @current_user.id == @user_id
    end
end
