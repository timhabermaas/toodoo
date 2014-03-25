require "gateways/in_memory_database"
require "ostruct"
require "use_cases/comment_on_task"

describe CommentOnTask do
  before do
    t = Task.new(title: "Some task")
    database.create t
    @task_id = t.id
  end

  let(:database) { InMemoryDatabase.new }
  let(:current_user) { double(id: 1) }
  subject { CommentOnTask.new(database, current_user, @task_id, comment_form) }

  context "comment valid" do
    let(:comment_form) { OpenStruct.new(content: "bla") }

    it "adds the comment to the task" do
      subject.call
      task = database.find Task, @task_id
      expect(task.comments.size).to eq 1
      expect(task.comments.first.content).to eq "bla"
    end
  end

  context "task does not exist" do
    it "throws a RecordNotFound exception" do
      expect { CommentOnTask.new(database, current_user, 200, OpenStruct.new).call }.to raise_error(RecordNotFound)
    end
  end
end
