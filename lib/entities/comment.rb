class Comment
  attr_reader :content, :author, :task
  attr_accessor :id

  def initialize attributes={}
    attributes.each do |key, value|
      instance_name = "@#{key}"
      instance_variable_set instance_name.to_sym, value
    end
  end

  def ==(other)
    # TODO compare author as well?
    other.id == id && other.content == content
  end
end
