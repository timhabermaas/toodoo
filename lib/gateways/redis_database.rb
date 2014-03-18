require "redis"
require "json"
require "gateways/errors"
require "entities"

class RedisDatabase
  def initialize(url)
    @redis = Redis.new url: url
  end

  def create record
    case record
    when Task
      create_task record
    when User
      create_user record
    end
  end

  def find klass, id
    if klass == Task
      find_task id
    elsif klass == User
      find_user id
    else
      raise RecordNotFound
    end
  end

  def update record
    case record
    when Task
      write_task record
    when User
      write_user record
    end
  end

  def delete record
    case record
    when Task
      delete_task record.id
    when User
      delete_user record.id
    end
  end

  def query_unfinished_todos_for_user user_id
    keys = @redis.smembers "users:#{user_id}:tasks:unfinished"
    return [] unless keys

    keys.map do |key|
      json = @redis.get "tasks:#{key}"
      build_task_from_json json
    end
  end

  def query_todos_for_user user_id
    keys = @redis.smembers "users:#{user_id}:tasks"
    return [] unless keys

    keys.map do |key|
      json = @redis.get "tasks:#{key}"
      build_task_from_json json
    end
  end

  private
    def create_task task
      id = @redis.incr "tasks:last_id"
      task.id = id
      write_task task
    end

    def create_user user
      id = @redis.incr "users:last_id"
      user.id = id
      json = {id: user.id, name: user.name}.to_json
      @redis.set "users:#{id}", json
    end

    def find_user id
      json = @redis.get "users:#{id}"
      raise RecordNotFound if json.nil?
      hash = JSON.parse json
      User.new hash
    end

    def find_task id
      json = @redis.get "tasks:#{id}"
      raise RecordNotFound if json.nil?
      build_task_from_json json
    end

    def build_task_from_json json
      hash = JSON.parse json
      hash["user"] = find_user hash["user_id"]
      Task.new hash
    end

    def delete_task id
      @redis.del "tasks:#{id}"
    end

    def write_task task
      json = {id: task.id, title: task.title, body: task.body, user_id: task.user.id, done: task.done?}.to_json
      @redis.set "tasks:#{task.id}", json
      @redis.sadd "users:#{task.user.id}:tasks", task.id
      @redis.sadd "users:#{task.user.id}:tasks:unfinished", task.id if !task.done?
    end
end
