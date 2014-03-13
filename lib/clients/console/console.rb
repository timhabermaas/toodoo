require "use_cases/list_unfinished_todos"
require "use_cases/list_todos"
require "use_cases/create_todo"
require "use_cases/mark_todo_as_done"
require "entities/user"
require "gateways/in_memory_database"

require "clients/console/todo_list_printer"

USER = User.new
USER.id = 32
DATABASE = InMemoryDatabase.new

loop do
  puts "Please choose an action"
  puts "-----------------------"
  puts
  puts "1.) Add a new Todo"
  puts "2.) List Todos"
  puts "3.) Mark Todo as done"
  puts "x.) Exit"
  answer = gets.chomp

  case answer
  when "1"
    puts "Please enter the title of the Todo"
    title = gets.chomp
    request = OpenStruct.new(title: title)

    CreateTodo.new(DATABASE, request, USER).call
  when "2"
    printer = TodoListPrinter.new ListTodos.new(DATABASE, USER.id, USER).call
    printer.print
  when "3"
    printer = TodoListPrinter.new ListUnfinishedTodos.new(DATABASE, USER).call
    printer.print

    puts "Which Todo do you want to mark finished?"
    id = gets.chomp
    if id != "0"
      MarkTodoAsDone.new(DATABASE, id.to_i, USER).call
    end
  when "x"
    break
  end
end
