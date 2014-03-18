require "gateways/in_memory_database"
require "use_cases/list_todos"
require "entities/task"

describe ListTodos do
  let(:database) { InMemoryDatabase.new }

  context "current user is the same as user" do
    it "lists all todos for this user" do
      todos = double
      user = double(id: 2)

      expect(database).to receive(:query_todos_for_user).with(Task, user.id).and_return todos
      expect(ListTodos.new(database, user, user.id).call).to eq todos
    end
  end

  context "current user is not the same as user" do
    it "throws Unauthorized exception" do
      expect {
        ListTodos.new(database, double(id: 2), 32).call
      }.to raise_error(Unauthorized)
    end
  end
end
