require "use_case_spec_helper"
require "use_cases/login"
require "use_cases/register_user"

describe Login do
  let(:database) { InMemoryDatabase.new }
  subject { Login.new(database, nil, login_form) }

  context "user name and password match" do
    let(:login_form) { OpenStruct.new(name: "peter", password: "peter") }

    before do
      @user = RegisterUser.new(database, double.as_null_object, nil, OpenStruct.new(name: "peter", password: "peter")).call
    end

    it "can login successfully" do
      user = subject.call
      expect(user).to eq @user
    end
  end

  context "user name found, but password wrong" do
    let(:login_form) { OpenStruct.new(name: "peter", password: "peter2") }

    before do
      RegisterUser.new(database, double.as_null_object, nil, OpenStruct.new(name: "peter", password: "peter")).call
    end

    it "raises a NotAuthenticated exception" do
      expect { subject.call }.to raise_error(NotAuthenticated)
    end
  end

  context "user name not found" do
    let(:login_form) { OpenStruct.new(name: "peter", password: "peter") }

    it "raises a RecordNotFound exception" do
      expect { subject.call }.to raise_error(NotAuthenticated)
    end
  end
end
