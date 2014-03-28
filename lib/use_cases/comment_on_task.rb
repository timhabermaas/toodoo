require "entities/task"
require "entities/user"

class CommentOnTask < Struct.new(:database, :mailer, :current_user, :task_id, :comment_form)
  def call
    comment_form.validate!

    task = database.find Task, task_id

    usernames = find_mentioned_usernames comment_form.content
    mentions = usernames.map do |n|
      database.query_user_by_name n
    end

    comment = Comment.new(task: task, content: comment_form.content, author: current_user)

    mentions.each do |m|
      mention_user_in_comment m, comment
    end

    database.create comment
    comment
  end

  private
    def find_mentioned_usernames text
      text.scan(/@[a-zA-Z]+/).map { |n| n[1..-1] }
    end

    def mention_user_in_comment user, comment
      mailer.send_mention_in_comment_mail user, comment
      comment.task.add_follower user
    end
end
