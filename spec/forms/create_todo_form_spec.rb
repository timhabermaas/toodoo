require "forms/create_todo_form"

describe CreateTodoForm do
  describe "validations" do
    describe "#title" do
      subject { CreateTodoForm.new(title: title) }

      context "given some random string" do
        let(:title) { "dafsd" }

        it "is valid" do
          expect{subject.validate!}.to_not raise_error
        end
      end

      context "given empty string" do
        let(:title) { "" }

        it "is not valid" do
          expect{subject.validate!}.to raise_error(ValidationError)
        end
      end

      context "given nil" do
        let(:title) { nil }

        it "is not valid" do
          expect{subject.validate!}.to raise_error(ValidationError)
        end
      end

      context "given just one character" do
        let(:title) { "a" }

        it "is not valid" do
          expect{subject.validate!}.to raise_error(ValidationError)
        end
      end
    end
  end
end
