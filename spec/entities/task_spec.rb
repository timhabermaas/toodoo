require "entities/task"

describe Task do
  describe "#done" do
    it "returns a CompletedTask" do
      todo = UnfinishedTask.new(title: "Clean").done
      expect(todo.title).to eq "Clean"
      expect(todo.done?).to eq true
      expect(todo.class).to eq CompletedTask
    end
  end
end
