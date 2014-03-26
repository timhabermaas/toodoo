class InMemoryMailer
  class Mail < Struct.new(:to, :from, :subject, :body); end

  attr_reader :mails

  def initialize
    @mails = []
  end

  def send_registration_mail(email)
    mails << Mail.new(email, nil, "Register User", "Welcome!")
  end
end
