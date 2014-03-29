require "entities/task"
require "entities/user"

class CommentOnTask < Struct.new(:database, :mailer, :current_user, :task_id, :comment_form)
  def call
    comment_form.validate!

    task = database.find Task, task_id
    comment = Comment.new(task: task, content: comment_form.content, author: current_user)

    take_care_of_mentioned_users_in comment

    database.create comment
    comment
  end

  private
    def take_care_of_mentioned_users_in comment
      usernames = find_mentioned_usernames comment.content
      mentioned_users = fetch_users_for_names usernames
      mention_users mentioned_users, comment
    end

    def find_mentioned_usernames text
      text.scan(/@[a-zA-Z]+/).map { |n| n[1..-1] }
    end

    def fetch_users_for_names names
      mentions = (names - [current_user.name]).map do |n|
        begin
          database.query_user_by_name n
        rescue RecordNotFound
        end
      end.compact
    end

    def mention_users users, comment
      users.each do |m|
        mention_user_in_comment m, comment
      end
    end

    def mention_user_in_comment user, comment
      mailer.send_mention_in_comment_mail user, comment
      comment.task.add_follower user
    end
end
