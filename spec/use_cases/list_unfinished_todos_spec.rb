require "use_cases/list_unfinished_todos"
require "gateways/in_memory_database"

describe ListUnfinishedTodos do
  let(:database) { InMemoryDatabase.new }
  let(:user) { double(id: 2) }

  context "current user asks for his tasks" do
    it "returns the unfinished todos" do
      tasks = double(:tasks)
      expect(database).to receive(:query_unfinished_todos_for_user).with(2).and_return(tasks)
      result = ListUnfinishedTodos.new(database, user, 2).call
      expect(result).to eq tasks
    end
  end

  context "current_user asks for todos for someone else" do
    it "raises an Unauthorized exception" do
      expect {
        current_user = double id: 1
        ListUnfinishedTodos.new(database, current_user, 2).call
      }.to raise_error(Unauthorized)
    end
  end

  context "user not logged in" do
    it "raises an Unauthorized exception" do
      expect {
        ListUnfinishedTodos.new(database, nil, 2).call
      }.to raise_error(Unauthorized)
    end
  end
end
