require "use_cases/list_unfinished_todos"
require "gateways/in_memory_database"

describe ListUnfinishedTodos do
  let(:database) { InMemoryDatabase.new }
  let(:user) { double(id: 2) }

  context "current user asks for his tasks" do
    before do
      # TODO this is actually testing the database layer. Use mocks instead?
      t = UnfinishedTask.new
      t.title = "Tidy up your room"
      t.user = user
      database.create t

      t = UnfinishedTask.new
      t.title = "Clean the dishes"
      t.user = user
      database.create t.done

      t = UnfinishedTask.new
      t.title = "Clean the dishes"
      t.user = double(id: 3)
      database.create t
    end

    it "returns the unfinished todos" do
      todos = ListUnfinishedTodos.new(database, user, 2).call
      expect(todos.size).to eq 1
      expect(todos.first.title).to eq "Tidy up your room"
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
