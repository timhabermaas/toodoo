require "gateways/in_memory_database"
require "use_cases/mark_todo_as_done"

describe MarkTodoAsDone do
  let(:database) { InMemoryDatabase.new }

  context "todo exists" do
    before do
      @user = double
      @todo = UnfinishedTask.new
      @todo.user = @user
      database.create @todo
    end

    context "todo belongs to user" do
      it "marks the todo as done" do
        subject = MarkTodoAsDone.new(database, @user, @todo.id)
        subject.call

        tasks = database.all(Task)
        expect(tasks.first.done?).to eq true
      end
    end

    context "todo doesn't belong user" do
      it "throws a Unauthorized exception" do
        user_2 = double

        expect {
          subject = MarkTodoAsDone.new(database, user_2, @todo.id)
          subject.call
        }.to raise_error Unauthorized
      end
    end
  end

  context "todo doesn't exist" do
    it "throws a RecordNotFound error" do
      expect {
        MarkTodoAsDone.new(database, 43, nil).call
      }.to raise_error(RecordNotFound)
    end
  end
end
