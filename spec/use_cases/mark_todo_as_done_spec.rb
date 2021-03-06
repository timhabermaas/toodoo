require "use_case_spec_helper"
require "use_cases/mark_todo_as_done"

describe MarkTodoAsDone do
  let(:database) { InMemoryDatabase.new }

  context "todo exists" do
    before do
      @user = User.new
      database.create @user
      @todo = Task.new user: @user
      database.create @todo
    end

    context "todo belongs to user" do
      it "marks the todo as done" do
        subject = MarkTodoAsDone.new(database, @user, @todo.id)
        subject.call

        task = database.find Task, @todo.id
        expect(task.done?).to eq true
      end
    end

    context "todo doesn't belong user" do
      it "throws a Unauthorized exception" do
        user_2 = User.new id: 4

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
