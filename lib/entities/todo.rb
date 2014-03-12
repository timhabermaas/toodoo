class Todo
  attr_accessor :title, :body, :user, :id

  def done!
    @status = "done"
  end

  def done?
    @status == "done"
  end
end
