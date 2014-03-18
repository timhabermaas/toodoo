require "use_cases/create_todo"
require "entities/task"
require "gateways/in_memory_database"

describe CreateTodo do
  let(:database) { InMemoryDatabase.new }
  let(:current_user) { double }
  subject { CreateTodo.new database, current_user, request }

  context "given valid request" do
    let(:request) { OpenStruct.new title: "Blub", body: "KA" }

    it "saves a Todo to the database" do
      subject.call

      expect(database.all(Task).size).to eq 1
      expect(database.all(Task).first.title).to eq "Blub"
      expect(database.all(Task).first.body).to eq "KA"
      expect(database.all(Task).first.user).to eq current_user
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

