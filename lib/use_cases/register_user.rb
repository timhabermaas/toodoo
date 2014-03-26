require "entities"

class RegisterUser < Struct.new(:database, :mailer, :current_user, :user_form)
  def call
    user = User.new name: user_form.name, password: user_form.password, email: user_form.email
    database.create user
    mailer.send_registration_mail user_form.email
    user
  end
end
