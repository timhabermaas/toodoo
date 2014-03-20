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
    result = map_for_class(klass).fetch id
    raise RecordNotFound unless result.is_a? klass
    result
  rescue KeyError
    raise RecordNotFound
  end

  def delete(record)
    map_for_class(record.class).delete record.id
  end

  def all(klass)
    map_for_class(klass).values.select { |r| r.is_a? klass }
  end

  def query_todos_for_user(user_id)
    all(Task).select { |t| t.user.id == user_id }
  end

  def query_unfinished_todos_for_user(user_id)
    all(Task).select { |t| t.user.id == user_id && !t.done? }
  end

  private
    def map_for_class klass
      if klass == UnfinishedTask || klass == CompletedTask
        klass = Task
      end
      @map[klass.to_s] ||= {}
    end
end
