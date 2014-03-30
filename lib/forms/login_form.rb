require "virtus"

class LoginForm
  include Virtus.model

  attribute :name, String
  attribute :password, String

  def validate!
    # TODO
  end
end
