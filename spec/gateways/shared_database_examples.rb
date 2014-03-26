require "entities"

shared_examples "a database supporting TooDoo" do

  describe "#create user" do
    let(:user) { User.new(name: "name", password: "password") }

    it "saves the user" do
      subject.create user
      expect(subject.find(User, user.id)).to eq user
    end

    context "username already exists" do
      it "throws a NotUnique exception" do
        subject.create user
        expect{ subject.create user }.to raise_error(NotUnique)
      end
    end
  end

  describe "tasks" do
    let(:task) { Task.new(title: "title", done: false) }
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
        expect(subject.query_graph_todos_for_user(user.id)).to eq []
        expect(subject.query_unfinished_todos_for_user(user.id)).to eq []
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

    describe "#find_graph" do
      before do
        subject.create task
        @comment_1 = Comment.new(content: "bla 1", task: task, author: user)
        subject.create @comment_1
        @comment_2 = Comment.new(content: "bla 2", task: task, author: user)
        subject.create @comment_2
      end

      it "fetches the comments" do
        expect(subject.find_graph(Task, task.id).comments).to eq [@comment_1, @comment_2]
      end
    end
  end

  describe "comments" do
    let(:user) { User.new(name: "Peter") }
    let(:task) { Task.new(title: "Clean up", user: user) }

    before do
      subject.create user
      subject.create task
    end

    describe "#create" do
      let(:comment) { Comment.new(content: "bla", author: user, task: task) }

      before do
        subject.create comment
      end

      it "saves the comment" do
        expect(subject.find(Comment, comment.id)).to eq comment
      end

      it "retreives the author" do
        expect(subject.find(Comment, comment.id).author).to eq user
      end
    end
  end

  describe "queries" do
    describe "query_user_by_name" do
      let(:user) { User.new name: "Peter" }

      before do
        subject.create user
      end

      context "user can be found" do
        it "returns the user" do
          expect(subject.query_user_by_name("Peter")).to eq user
        end
      end

      context "user can not be found" do
        it "raises RecordNotFound exception" do
          expect { subject.query_user_by_name("Hans") }.to raise_error(RecordNotFound)
        end
      end
    end

    describe "query_graph_todos_for_user" do
      let(:user_1) { User.new name: "Peter" }
      let(:user_2) { User.new name: "Dieter" }

      before do
        subject.create user_1
        subject.create user_2
        @task = Task.new(title: "bla", user: user_1, done: false)

        subject.create @task
        subject.create Task.new(title: "blub", user: user_2, done: true)

        @comment = Comment.new(content: "muh", author: user_1, task: @task)
        subject.create @comment
      end

      it "finds only the todos for the given user" do
        expect(subject.query_graph_todos_for_user(user_1.id)).to eq [@task]
      end

      it "includes the comments" do
        expect(subject.query_graph_todos_for_user(user_1.id).first.comments).to eq [@comment]
      end
    end

    describe "query_unfinished_todos_for_user" do
      let(:user_1) { User.new name: "Peter" }
      let(:user_2) { User.new name: "Dieter" }

      before do
        subject.create user_1
        subject.create user_2
        @task_1 = Task.new(title: "bla", user: user_1, done: false)
        @task_2 = Task.new(title: "bla", user: user_1, done: false)

        subject.create @task_1
        subject.create @task_2
        subject.create Task.new(title: "blub", user: user_2, done: false)
        subject.create Task.new(title: "ble", user: user_1, done: true)

        updated_task = @task_2.done
        subject.update updated_task
      end

      it "returns only the unfinished tasks for the given user" do
        tasks = subject.query_unfinished_todos_for_user user_1.id
        expect(tasks).to eq [@task_1]
      end
    end
  end
end
