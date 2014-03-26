class Task
  attr_accessor :title, :user, :id, :comments

  def initialize attributes={}
    @done = false
    @comments = []

    attributes.each do |key, value|
      instance_name = "@#{key}"
      instance_variable_set instance_name.to_sym, value
    end
  end

  def ==(other)
    other.class == self.class && other.id == self.id && other.done? == self.done? && other.title == self.title
  end

  def done
    dup.tap do |t|
      t.instance_variable_set :@done, true
    end
  end

  def done?
    @done
  end

  def comment_size
    comments.size
  end
end
