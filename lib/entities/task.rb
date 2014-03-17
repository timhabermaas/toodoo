class Task
  attr_accessor :title, :body, :user, :id

  def initialize attributes={}
    attributes.each do |key, value|
      public_send "#{key}=", value
    end
  end
end

class UnfinishedTask < Task
  def done?
    false
  end

  def done
    CompletedTask.new title: title, body: body, user: user, id: id
  end
end

class CompletedTask < Task
  def done?
    true
  end
end
