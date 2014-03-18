require "entities"

shared_examples "a database supporting TooDoo" do

  describe "#create user" do
    let(:user) { User.new(name: "name") }

    it "saves the user" do
      subject.create user
      expect(subject.find(User, user.id)).to eq user
    end
  end

  describe "tasks" do
    let(:task) { Task.new(title: "title", body: "body", done: false) }
    let(:user) { User.new(name: "name") }

    before do
      subject.create user
      task.user = user
    end

    describe "#create" do
      it "creates the todo" do
        subject.create task
        expect(subject.find Task, task.id).to eq task
      end
    end

    describe "#delete" do
      before do
        subject.create task
      end

      it "removes the task" do
        subject.delete task
        expect{subject.find Task, task.id}.to raise_error RecordNotFound
      end
    end

    describe "#update" do
      before do
        subject.create task
      end

      it "updates the task in place" do
        task.title = "title 2"
        subject.update task
        expect(subject.find Task, task.id).to eq task
      end
    end

    describe "#find" do
      before do
        subject.create task
      end

      it "fetches the user" do
        expect(subject.find(Task, task.id).user).to eq user
      end
    end
  end

  describe "queries" do
    describe "query_user_by_name" do
      let(:user_1) { User.new name: "Peter" }
      let(:user_2) { User.new name: "Dieter" }

      before do
        subject.create user_1
        subject.create user_2
      end

      context "user can be found" do
        it "returns the user" do
          expect(subject.query_user_by_name("Peter")).to eq user_1
        end
      end

      context "user can not be found" do
        it "raises RecordNotFound exception" do
          expect { subject.query_user_by_name("Hans") }.to raise_error(RecordNotFound)
        end
      end
    end

    describe "query_todos_for_user" do
      let(:user_1) { User.new name: "Peter" }
      let(:user_2) { User.new name: "Dieter" }

      before do
        subject.create user_1
        subject.create user_2
        @task = Task.new(title: "bla", user: user_1, done: false)

        subject.create @task
        subject.create Task.new(title: "blub", user: user_2, done: true)
      end

      it "finds only the todos for the given user" do
        expect(subject.query_todos_for_user(user_1.id)).to eq [@task]
      end
    end

    describe "query_unfinished_todos_for_user" do
      let(:user_1) { User.new name: "Peter" }
      let(:user_2) { User.new name: "Dieter" }

      before do
        subject.create user_1
        subject.create user_2
        @task = Task.new(title: "bla", user: user_1, done: false)

        subject.create @task
        subject.create Task.new(title: "blub", user: user_2, done: false)
        subject.create Task.new(title: "ble", user: user_1, done: true)
      end

      it "returns only the unfinished tasks for the given user" do
        tasks = subject.query_unfinished_todos_for_user user_1.id
        expect(tasks).to eq [@task]
      end
    end
  end
end
