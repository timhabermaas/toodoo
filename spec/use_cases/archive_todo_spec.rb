require "use_case_spec_helper"
require "use_cases/create_todo"
require "use_cases/archive_todo"

describe ArchiveTodo do
  let(:database) { InMemoryDatabase.new }
  let(:request) { OpenStruct.new(title: "muh") }
  let(:user) { User.new(name: "muh") }

  before do
    database.create user
    @todo = CreateTodo.new(database, user, request).call
  end

  context "todo belongs to user" do
    it "removes the todo" do
      ArchiveTodo.new(database, user, @todo.id).call
      expect{database.find(Task, @todo.id)}.to raise_error(RecordNotFound)
    end
  end

  context "todo doesn't belong to user" do
    it "raises a Unauthorized exception" do
      other_user = double(id: 3)

      expect {
        ArchiveTodo.new(database, other_user, @todo.id).call
      }.to raise_error Unauthorized
    end
  end
end
