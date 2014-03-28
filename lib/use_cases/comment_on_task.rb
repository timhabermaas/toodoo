require "entities/task"
require "entities/user"

class CommentOnTask < Struct.new(:database, :mailer, :current_user, :task_id, :comment_form)
  def call
    comment_form.validate!

    task = database.find Task, task_id

    user_names = find_mentioned_users comment_form.content
    mentions = user_names.map do |n|
      database.query_user_by_name n
    end

    comment = Comment.new(mentions: mentions, task: task, content: comment_form.content, author: current_user)

    mentions.each { |m| mailer.send_mention_in_comment_mail(m, comment) }
    mentions.each { |m| task.add_follower m }

    database.create comment
    comment
  end

  private
    def find_mentioned_users text
      text.scan(/@[a-zA-Z]+/).map { |n| n[1..-1] }
    end
end
