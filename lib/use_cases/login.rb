NotAuthenticated = Class.new StandardError

class Login < Struct.new(:database, :current_user, :login_form)
  def call
    user = fetch_user_by_name login_form.name

    if user.password == login_form.password
      user
    else
      raise NotAuthenticated
    end
  end

  private
    def fetch_user_by_name(name)
      database.query_user_by_name login_form.name
    rescue RecordNotFound
      raise NotAuthenticated
    end
end
