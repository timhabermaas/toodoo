require "use_cases/list_unfinished_todos"
require "gateways/in_memory_database"

describe ListUnfinishedTodos do
  let(:database) { InMemoryDatabase.new }
  let(:user) { double(id: 2) }

  before do
    # TODO this is actually testing the database layer. Use mocks instead?
    t = Todo.new
    t.title = "Tidy up your room"
    t.user = user
    database.create t

    t = Todo.new
    t.title = "Clean the dishes"
    t.user = user
    t.done!
    database.create t

    t = Todo.new
    t.title = "Clean the dishes"
    t.user = double(id: 3)
    database.create t
  end

  it "returns the unfinished todos" do
    todos = ListUnfinishedTodos.new(database, 2, user).call
    expect(todos.size).to eq 1
    expect(todos.first.title).to eq "Tidy up your room"
  end
end
