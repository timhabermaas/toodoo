require "entities"

class RegisterUser < Struct.new(:database, :current_user, :user_form)
  def call
    user = User.new name: user_form.name, password: user_form.password
    database.create user
    user
  end
end
