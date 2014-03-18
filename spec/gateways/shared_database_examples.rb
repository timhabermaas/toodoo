require "entities/task"

shared_examples "a database supporting TooDoo" do
  describe "#create" do
    context "UnfinishedTask" do
      it "saves the object" do
        t = UnfinishedTask.new
        subject.create t
        expect(subject.all UnfinishedTask).to eq [t]
        expect(subject.all CompletedTask).to eq []
        expect(subject.all Task).to eq [t]

        expect(subject.find UnfinishedTask, t.id).to eq t
        expect{subject.find CompletedTask, t.id}.to raise_error RecordNotFound
        expect(subject.find Task, t.id).to eq t
      end
    end

    context "CompletedTask" do
      it "saves the object" do
        t = CompletedTask.new
        subject.create t
        expect(subject.all CompletedTask).to eq [t]
        expect(subject.all UnfinishedTask).to eq []
        expect(subject.all Task).to eq [t]

        expect(subject.find CompletedTask, t.id).to eq t
        expect{subject.find UnfinishedTask, t.id}.to raise_error RecordNotFound
        expect(subject.find Task, t.id).to eq t
      end
    end
  end

  describe "#delete" do
    let(:task) { UnfinishedTask.new }

    before do
      subject.create task
      subject.delete task
    end

    it "removes the task" do
      expect(subject.all(UnfinishedTask)).to eq []
      expect{subject.find(UnfinishedTask, task.id)}.to raise_error RecordNotFound
    end
  end

  describe "#update" do
    let(:task) { UnfinishedTask.new }

    before do
      subject.create task

      @finised_task = task.done

      subject.update @finised_task
    end

    it "overwrites the exisiting task" do
      expect{subject.find UnfinishedTask, task.id}.to raise_error RecordNotFound
      expect(subject.find CompletedTask, task.id).to eq @finised_task
    end
  end

  describe "#query_todos_for_user" do
    let(:user_1) { double(:user, id: 1) }
    let(:user_2) { double(:user, id: 2) }

    let(:task_1) { CompletedTask.new user: user_1 }
    let(:task_2) { CompletedTask.new user: user_2 }
    let(:task_3) { UnfinishedTask.new user: user_1 }

    before do
      subject.create task_1
      subject.create task_2
      subject.create task_3
    end

    it "fetches only the tasks for the given user" do
      expect(subject.query_todos_for_user(CompletedTask, 1)).to eq [task_1]
      expect(subject.query_todos_for_user(CompletedTask, 2)).to eq [task_2]
      expect(subject.query_todos_for_user(UnfinishedTask, 1)).to eq [task_3]
    end
  end
end
