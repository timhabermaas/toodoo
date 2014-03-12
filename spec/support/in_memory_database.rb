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

  def all(klass)
    map_for_class(klass).values
  end

  private
    def map_for_class klass
      @map[klass.to_s] ||= {}
    end
end
