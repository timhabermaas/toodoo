require "pony"

class SendgridMailer
  def initialize(username, password)
    Pony.options = {
      :via => :smtp,
      :via_options => {
        :address => 'smtp.sendgrid.net',
        :port => '587',
        :domain => 'heroku.com',
        :user_name => username,
        :password => password,
        :authentication => :plain,
        :enable_starttls_auto => true
      }
    }
  end

  def send_registration_mail email
    Pony.mail(to: email, from: "info@toodoo.com", subject: "Registration at toodoo.com", body: "Welcome!")
  end
end
