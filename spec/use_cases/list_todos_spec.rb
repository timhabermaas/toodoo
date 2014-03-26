require "use_case_spec_helper"
require "use_cases/list_todos"

describe ListTodos do
  let(:database) { InMemoryDatabase.new }

  context "current user is the same as user" do
    it "lists all todos for this user" do
      todos = double
      user = double(id: 2)

      expect(database).to receive(:query_todos_for_user).with(user.id).and_return todos
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
