require "use_case_spec_helper"
require "use_cases/comment_on_task"

describe CommentOnTask do
  before do
    t = Task.new(title: "Some task")
    database.create t
    @task_id = t.id
  end

  let(:current_user) { double(id: 1) }
  subject { CommentOnTask.new(database, current_user, @task_id, comment_form) }

  context "comment valid" do
    let(:comment_form) { OpenStruct.new(content: "bla") }
    let(:result) { subject.call }

    it "saves the comment" do
      comment = database.find Comment, result.id
      expect(comment.content).to eq "bla"
    end

    it "saves the author" do
      comment = database.find Comment, result.id
      expect(comment.author).to eq current_user
    end
  end

  context "task does not exist" do
    it "throws a RecordNotFound exception" do
      expect { CommentOnTask.new(database, current_user, 200, OpenStruct.new).call }.to raise_error(RecordNotFound)
    end
  end
end
