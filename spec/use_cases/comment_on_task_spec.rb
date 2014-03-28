require "use_case_spec_helper"
require "use_cases/comment_on_task"

describe CommentOnTask do
  let(:current_user) { User.new(name: "user") }

  before do
    database.create current_user
    t = Task.new(title: "Some task")
    database.create t
    @task_id = t.id
  end

  let(:mailer) { double.as_null_object }
  subject { CommentOnTask.new(database, mailer, current_user, @task_id, comment_form) }

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

  context "users mentioned" do
    let(:dieter) { User.new(name: "dieter") }
    let(:peter) { User.new(name: "peter") }

    before do
      database.create dieter
      database.create peter
    end

    let(:comment_form) { OpenStruct.new(content: "@peter or @dieter should take care of this") }

    let!(:result) { subject.call }

    it "sends an email to the guys being mentioned" do
      expect(mailer).to have_received(:send_mention_in_comment_mail).with(peter, result)
      expect(mailer).to have_received(:send_mention_in_comment_mail).with(dieter, result)
    end

    it "adds the mentioned users as followers to the task at hand" do
      expect(database.find(Task, @task_id).followers).to include(peter, dieter)
    end
  end

  context "mentioning himself" do
    let(:comment_form) { OpenStruct.new(content: "I'm mentioning me: @user") }

    it "doesn't send an email" do
      subject.call
      expect(mailer).to_not have_received(:send_mention_in_comment_mail)
    end
  end

  context "mentioning someone who doesn't exist" do
    let(:comment_form) { OpenStruct.new(content: "@randomuser") }

    it "doesn't send an email" do
      subject.call
      expect(mailer).to_not have_received(:send_mention_in_comment_mail)
    end
  end

  context "task does not exist" do
    it "throws a RecordNotFound exception" do
      expect { CommentOnTask.new(database, mailer, current_user, 200, OpenStruct.new).call }.to raise_error(RecordNotFound)
    end
  end
end
