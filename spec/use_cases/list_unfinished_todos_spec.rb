require "use_cases/list_unfinished_todos"
require "support/in_memory_database"

describe ListUnfinishedTodos do
  let(:database) { InMemoryDatabase.new }
  let(:user) { double }

  def create_todo(task, user)
  end

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
    t.user = double
    database.create t
  end

  it "returns the unfinished todos" do
    ListUnfinishedTodos.new(database, user).call do |todos|
      expect(todos.size).to eq 1
      expect(todos.first.title).to eq "Tidy up your room"
    end
  end
end
