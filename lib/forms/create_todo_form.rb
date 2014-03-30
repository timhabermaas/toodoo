require "virtus"
require "active_model"
require "forms/errors"

class CreateTodoForm
  include Virtus.model
  include ActiveModel::Validations

  attribute :title, String

  validates :title, presence: true
  validates :title, length: {minimum: 2}

  def validate!
    raise ValidationError.new(errors) unless valid?
  end
end
