class RegisterUserForm
  include Virtus.model

  attribute :name, String
  attribute :password, String
  attribute :password_confirmation, String

  def validate!
    # TODO
  end
end
