class TodoListPrinter
  class TodoWrapper
    def initialize todo
      @todo = todo
    end

    def print
      puts "[#{box_content}] #{@todo.title} (#{@todo.id})"
    end

    private
      def box_content
        @todo.done? ? "x" : " "
      end
  end

  def initialize todos
    @todos = todos
  end

  def print
    puts
    puts "----"
    @todos.each do |t|
      TodoWrapper.new(t).print
    end
    puts "----"
    puts
  end
end
