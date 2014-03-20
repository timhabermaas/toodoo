require "entities/task"

describe Task do
  describe "#done" do
    it "returns a new task which has been marked as done" do
      task = Task.new(title: "Clean")
      completed_task = task.done
      expect(completed_task.title).to eq "Clean"
      expect(task.done?).to eq false
      expect(completed_task.done?).to eq true
    end
  end
end
