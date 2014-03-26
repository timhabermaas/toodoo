require "gateways/errors"
require "entities"

class InMemoryDatabase
  def initialize
    @map = {}
  end

  def create(record)
    if record.class == User
      begin
        query_user_by_name record.name
        raise NotUnique
      rescue RecordNotFound
      end
    end
    if record.class == Comment
      record.task.comments << record
    end
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

  def find_graph(klass, id)
    find klass, id
  end

  def delete(record)
    map_for_class(record.class).delete record.id
  end

  def all(klass)
    map_for_class(klass).values.select { |r| r.is_a? klass }
  end

  def query_user_by_name(name)
    user = all(User).find { |u| u.name == name }
    raise RecordNotFound unless user
    user
  end

  def query_graph_todos_for_user(user_id)
    all(Task).select { |t| t.user.id == user_id }
  end

  def query_unfinished_todos_for_user(user_id)
    all(Task).select { |t| t.user.id == user_id && !t.done? }
  end

  private
    def map_for_class klass
      @map[klass.to_s] ||= {}
    end
end
