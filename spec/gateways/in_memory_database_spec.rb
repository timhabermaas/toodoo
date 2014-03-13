require "gateways/in_memory_database"
require "entities/todo"

describe InMemoryDatabase do
  describe "#create" do
    it "saves the object" do
      t = Todo.new
      subject.create t
      expect(subject.all Todo).to eq [t]
    end
  end

  describe "#find" do
    it "finds objects by id" do
      t = Todo.new
      subject.create t
      expect(subject.find Todo, t.id).to eq t
    end
  end

  describe "#update" do
    it "updates the object" do
      t = Todo.new
      t.title = "muh"
      subject.create t
      t.title = "muh2"
      subject.update t
      expect(subject.all(Todo).first.title).to eq "muh2"
    end
  end
end
