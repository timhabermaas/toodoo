require "toodoo"
require "forms"
require "gateways/in_memory_database"
require "clients/console/todo_list_printer"

APP = Toodoo.new(InMemoryDatabase.new)

def menu(*choices)
  puts "Please choose an action"
  puts "-----------------------"
  puts
  choices.each_with_index do |choice, i|
    puts "#{i + 1}.) #{choice}"
  end
  choice = gets.chomp
  choice.to_i - 1
end

def register_form
  puts "enter your name"
  name = gets.chomp
  puts "enter your password"
  password = gets.chomp
  request = RegisterUserForm.new(name: name, password: password)
  APP.register_user request
end

def login_form
  puts "enter your name"
  name = gets.chomp
  puts "enter your password"
  password = gets.chomp
  request = LoginForm.new(name: name, password: password)
  APP.login request
end

def login_screen
  choice = menu("Register user", "Login")
  case choice
  when 0
    register_form
  when 1
    login_form
  end
end

def application_screen
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
      request = CreateTodoForm.new(title: title)

      APP.create_todo request
    when "2"
      printer = TodoListPrinter.new APP.list_my_todos
      printer.print
    when "3"
      printer = TodoListPrinter.new APP.list_my_unfinished_todos
      printer.print

      puts "Which Todo do you want to mark finished?"
      id = gets.chomp
      if id != "0"
        APP.mark_todo_as_done id.to_i
      end
    when "x"
      break
    end
  end
end

login_screen
application_screen
