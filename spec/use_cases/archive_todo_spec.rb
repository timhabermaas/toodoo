require "support/in_memory_database"
require "use_cases/create_todo"
require "use_cases/archive_todo"

describe ArchiveTodo do
  let(:database) { InMemoryDatabase.new }
  let(:request) { OpenStruct.new(title: "muh") }
  let(:user) { double }

  before do
    @todo = CreateTodo.new(database, request, user).call
  end

  context "todo belongs to user" do
    it "removes the todo" do
      ArchiveTodo.new(database, @todo.id, user).call
      expect(database.all(Todo).size).to eq 0
    end
  end

  context "todo doesn't belong to user" do
    it "raises a Unauthorized exception" do
      other_user = double

      expect {
        ArchiveTodo.new(database, @todo.id, other_user).call
      }.to raise_error Unauthorized
    end
  end
end
