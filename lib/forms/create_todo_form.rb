class CreateTodoForm
  include Virtus.model

  attribute :title, String

  def validate!
  end
end
