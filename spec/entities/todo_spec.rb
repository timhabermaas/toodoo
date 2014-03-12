require "entities/todo"

describe Todo do
  describe "#done!" do
    it "marks the todo as done" do
      subject.done!
      expect(subject.done?).to eq true
    end
  end
end
