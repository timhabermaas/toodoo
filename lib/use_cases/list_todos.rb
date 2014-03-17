require "use_cases/errors"

class ListTodos
  def initialize database, user_id, current_user
    @database = database
    @user_id = user_id
    @current_user = current_user
  end

  def call
    authorize!
    @database.query_todos_for_user Task, @current_user.id
  end

  def authorize!
    raise Unauthorized unless @current_user.id == @user_id
  end
end
