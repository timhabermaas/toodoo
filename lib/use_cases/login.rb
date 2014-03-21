NotAuthenticated = Class.new StandardError

class Login < Struct.new(:database, :current_user, :login_form)
  def call
    database.all(User)
    user = database.query_user_by_name login_form.name
    if user.password == login_form.password
      user
    else
      raise NotAuthenticated
    end
  end
end
