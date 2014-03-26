require "entities/task"
require "entities/user"

class CommentOnTask < Struct.new(:database, :current_user, :task_id, :comment_form)
  def call
    comment_form.validate!

    task = database.find Task, task_id

    comment = Comment.new(task: task, content: comment_form.content, author: current_user)
    database.create comment
    comment
  end
end
