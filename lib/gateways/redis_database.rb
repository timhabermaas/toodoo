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

  def query_user_by_name name
    user_id = @redis.get "users:names:#{name}"
    find User, user_id
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
      set_new_id task
      write_task task
    end

    def create_user user
      set_new_id user
      write_user user
    end

    def find_user id
      json = @redis.get "#{key_for(User)}:#{id}"
      raise RecordNotFound if json.nil?
      build_user_from_json json
    end

    def find_task id
      json = @redis.get "#{key_for(Task)}:#{id}"
      raise RecordNotFound if json.nil?
      build_task_from_json json
    end

    def build_task_from_json json
      hash = JSON.parse json
      hash["user"] = find_user hash["user_id"]
      Task.new hash
    end

    def build_user_from_json json
      hash = JSON.parse json
      User.new hash
    end

    def delete_task id
      task = find Task, id
      @redis.del "#{key_for(Task)}:#{id}"
      @redis.srem "users:#{task.user.id}:tasks", id
      @redis.srem "users:#{task.user.id}:tasks:unfinished", id
    end

    def write_task task
      json = {id: task.id, title: task.title, user_id: task.user.id, done: task.done?}.to_json
      @redis.set "#{key_for(Task)}:#{task.id}", json
      @redis.sadd "users:#{task.user.id}:tasks", task.id
      @redis.sadd "users:#{task.user.id}:tasks:unfinished", task.id if !task.done?
      @redis.srem "users:#{task.user.id}:tasks:unfinished", task.id if task.done?
    end

    def write_user user
      raise NotUnique if @redis.get "users:names:#{user.name}"

      json = {id: user.id, name: user.name, password: user.password}.to_json
      @redis.set "#{key_for(User)}:#{user.id}", json
      @redis.set "users:names:#{user.name}", user.id
    end

    def set_new_id record
      id = @redis.incr "#{key_for(record.class)}:last_id"
      record.id = id
    end

    def key_for klass
      return "users" if klass == User
      return "tasks" if [Task, UnfinishedTask, CompletedTask].include? klass
      raise "Unknown klass to serialize (tried to serialize #{klass})"
    end
end
