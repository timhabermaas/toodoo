RecordNotFound = Class.new StandardError

class InMemoryDatabase
  def initialize
    @map = {}
  end

  def create(record)
    id = rand 20000
    record.id = id
    map_for_class(record.class)[id] = record
  end

  def update(record)
    map_for_class(record.class)[record.id] = record
  end

  def find(klass, id)
    map_for_class(klass).fetch id
  rescue KeyError
    raise RecordNotFound
  end

  def delete(record)
    map_for_class(record.class).delete record.id
  end

  def all(klass)
    map_for_class(klass).values
  end

  def query_todo_unfinished_for_user(klass, user)
    all(klass).reject(&:done?).select { |t| t.user == user }
  end

  def query_todos_for_user(klass, user_id)
    all(klass).select { |t| t.user.id == user_id }
  end

  private
    def map_for_class klass
      @map[klass.to_s] ||= {}
    end
end
