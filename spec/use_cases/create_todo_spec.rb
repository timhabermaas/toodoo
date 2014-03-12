require "use_cases/create_todo"
require "entities/todo"
require_relative "../support/in_memory_database"

describe CreateTodo do
  let(:database) { InMemoryDatabase.new }
  let(:current_user) { double }
  subject { CreateTodo.new database, request, current_user }

  context "given valid request" do
    let(:request) { OpenStruct.new title: "Blub", body: "KA" }

    it "saves a Todo to the database" do
      subject.call

      expect(database.all(Todo).size).to eq 1
      expect(database.all(Todo).first.title).to eq "Blub"
      expect(database.all(Todo).first.body).to eq "KA"
      expect(database.all(Todo).first.user).to eq current_user
    end
  end

  context "given invalid request" do
    let(:request) { OpenStruct.new title: "Blub", body: "KA" }

    before do
      expect(request).to receive(:validate!).and_raise ValidationError.new([])
    end

    it "raises a ValidationError" do
      expect {
        subject.call
      }.to raise_error(ValidationError)
    end
  end
end

