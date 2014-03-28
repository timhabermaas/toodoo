class InMemoryMailer
  class Mail < Struct.new(:to, :from, :subject, :body); end

  attr_reader :mails

  def initialize
    @mails = []
  end

  def send_registration_mail(email)
    mails << Mail.new(email, nil, "Register User", "Welcome!")
  end

  def send_mention_in_comment_mail(user, comment)
    mails << Mail.new(user.email, nil, "You've been mentioned by #{comment.author.name}", "He wrote: #{comment.content}")
  end
end
