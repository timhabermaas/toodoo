class ConsolePrintMailer
  def send_registration_mail(email)
    wrap_mail do

      puts "Trying to send registration email to #{email}"
    end
  end

  def send_mention_in_comment_mail(user, comment)
    wrap_mail do
      puts "Trying to send a mail to #{user.email} about being mentioned by #{comment.author.name}"
      puts "Body: #{comment.content}"
    end
  end

  private
    def wrap_mail
      puts "---Mail---"
      yield
      puts "---Mail---"
    end
end
