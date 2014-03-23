class Task
  attr_accessor :title, :user, :id

  def initialize attributes={}
    @done = false
    attributes.each do |key, value|
      instance_name = "@#{key}"
      instance_variable_set instance_name.to_sym, value
    end
  end

  def ==(other)
    other.class == self.class && other.id == self.id && other.done? == self.done? && other.title == self.title
  end

  def done
    Task.new title: title, user: user, id: id, done: true
  end

  def done?
    @done
  end
end
