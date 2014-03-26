require "use_case_spec_helper"
require "use_cases/register_user"

describe RegisterUser do
  let(:database) { InMemoryDatabase.new }

  subject { RegisterUser.new(database, nil, user_form) }

  context "valid request" do
    let(:user_form) { OpenStruct.new(name: "Peter", password: "peter", password_confirmation: "peter") }

    it "saves the user to the database" do
      user = subject.call

      user_in_db = database.find User, user.id
      expect(user_in_db.name).to eq "Peter"
      expect(user_in_db.password).to eq "peter"
    end
  end

  context "username already exists" do
    pending "notify the user without exposing NotUnique exception"
  end
end
