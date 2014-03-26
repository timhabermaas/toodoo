require "use_case_spec_helper"
require "use_cases/show_task"

describe ShowTask do
  let(:database) { InMemoryDatabase.new }
  let(:current_user) { User.new(name: "Peter") }
  subject { described_class.new(database, current_user, @task_id) }

  before do
    database.create current_user
  end

  context "task belongs to user" do
    before do
      task = Task.new(user: current_user, title: "bla")
      database.create task
      comment = Comment.new(author: current_user, content: "bla", task: task)
      database.create comment

      @task_id = task.id
    end

    it "returns the task" do
      expect(subject.call.title).to eq "bla"
    end

    it "returns the comments" do
      expect(subject.call.comments.size).to eq 1
    end
  end

  context "task doesn't belong to current_user" do
    before do
      other_user = User.new(name: "Other")
      database.create other_user
      task = Task.new(title: "bla", user: other_user)
      database.create task
      @task_id = task.id
    end

    it "throws an Unauthorized exception" do
      expect { subject.call }.to raise_error(Unauthorized)
    end
  end
end
