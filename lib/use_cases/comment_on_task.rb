require "entities/task"
require "entities/user"

class CommentOnTask < Struct.new(:database, :mailer, :current_user, :task_id, :comment_form)
  def call
    comment_form.validate!

    task = database.find Task, task_id
    comment = Comment.new(task: task, content: comment_form.content, author: current_user)
    database.create comment

    take_care_of_mentioned_users_in comment

    comment
  end

  private
    def take_care_of_mentioned_users_in comment
      mentioned_users = mentioned_users_in comment
      email_users mentioned_users, comment
      make_users_followers mentioned_users, comment.task
    end

    def email_users users, comment
      users.each { |u| mailer.send_mention_in_comment_mail u, comment }
    end

    def make_users_followers users, task
      users.each { |u| task.add_follower u }
    end

    def mentioned_users_in comment
      fetch_users_for_names usernames_in_comment(comment)
    end

    def usernames_in_comment comment
      comment.content.scan(/@[a-zA-Z]+/).map { |n| n[1..-1] }
    end

    def fetch_users_for_names names
      (names - [current_user.name]).map do |n|
        begin
          database.query_user_by_name n
        rescue RecordNotFound
        end
      end.compact
    end
end
