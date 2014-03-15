require "toodoo"
require "gateways/in_memory_database"
require "clients/console/todo_list_printer"

USER = User.new
USER.id = 32
toodoo = Toodoo.new(InMemoryDatabase.new, USER)

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

    toodoo.create_todo request
  when "2"
    printer = TodoListPrinter.new toodoo.list_todos(USER.id)
    printer.print
  when "3"
    printer = TodoListPrinter.new toodoo.list_unfinished_todos(USER.id)
    printer.print

    puts "Which Todo do you want to mark finished?"
    id = gets.chomp
    if id != "0"
      toodoo.mark_todo_as_done id.to_i
    end
  when "x"
    break
  end
end
