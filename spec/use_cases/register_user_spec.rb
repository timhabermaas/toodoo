require "use_case_spec_helper"
require "use_cases/register_user"

describe RegisterUser do
  let(:database) { InMemoryDatabase.new }
  let(:mailer) { double(:mailer).as_null_object }

  subject { RegisterUser.new(database, mailer, nil, user_form) }

  context "valid request" do
    let(:user_form) { OpenStruct.new(name: "Peter", email: "foo@bar.com", password: "peter", password_confirmation: "peter") }
    before do
      @result = subject.call
    end

    it "saves the user to the database" do
      user_in_db = database.find User, @result.id
      expect(user_in_db.name).to eq "Peter"
      expect(user_in_db.email).to eq "foo@bar.com"
      expect(user_in_db.password).to eq "peter"
    end

    it "sends the user an email" do
      expect(mailer).to have_received(:send_registration_mail).with("foo@bar.com")
    end
  end

  context "username already exists" do
    pending "notify the user without exposing NotUnique exception"
  end
end
