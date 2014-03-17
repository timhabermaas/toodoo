require "gateways/in_memory_database"
require "entities/task"

describe InMemoryDatabase do
  describe "#create" do
    context "UnfinishedTask" do
      it "saves the object" do
        t = UnfinishedTask.new
        subject.create t
        expect(subject.all UnfinishedTask).to eq [t]
        expect(subject.all CompletedTask).to eq []
        expect(subject.all Task).to eq [t]
      end
    end

    context "CompletedTask" do
      it "saves the object" do
        t = CompletedTask.new
        subject.create t
        expect(subject.all CompletedTask).to eq [t]
        expect(subject.all UnfinishedTask).to eq []
        expect(subject.all Task).to eq [t]
      end
    end
  end

  describe "#find" do
    it "finds objects by id" do
      t = Task.new
      subject.create t
      expect(subject.find Task, t.id).to eq t
    end
  end

  describe "#update" do
    it "updates the object" do
      t = Task.new
      t.title = "muh"
      subject.create t
      t.title = "muh2"
      subject.update t
      expect(subject.all(Task).first.title).to eq "muh2"
    end
  end
end
