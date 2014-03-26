class TodoDetailsPrinter < Struct.new(:task)
  def print
    puts task.title
    puts "#" * task.title.size
    puts
    puts "Comments:"
    puts "---------"
    task.comments.each do |comment|
      puts "* #{comment.content} (#{comment.author.name})"
    end
  end
end
