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
    when Comment
      create_comment record
    end
  end

  def find klass, id
    if klass == Task
      find_task id
    elsif klass == User
      find_user id
    elsif klass == Comment
      find_comment id
    else
      raise RecordNotFound
    end
  end

  def find_graph klass, id
    if klass == Task
      find_graph_task id
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
    keys = members_of "users:#{user_id}:tasks:unfinished"

    fetch_tasks_from_keys keys
  end

  def query_graph_todos_for_user user_id
    keys = members_of "users:#{user_id}:tasks"

    fetch_graph_tasks_from_keys keys
  end

  def query_todos_for_user user_id
    query_graph_todos_for_user user_id
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

    def create_comment comment
      set_new_id comment
      write_comment comment
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

    def find_comment id
      json = @redis.get "#{key_for(Comment)}:#{id}"
      raise RecordNotFound if json.nil?
      build_comment_from_json json
    end

    def find_graph_task id
      task = find_task id
      task.comments = fetch_comments_for_task task
      task
    end

    def fetch_comments_for_task task
      comment_ids = @redis.lrange "tasks:#{task.id}:comments", 0, -1
      comment_ids.map do |comment_id|
        find_comment comment_id
      end
    end

    def fetch_tasks_from_keys keys
      keys.map do |key|
        json = @redis.get "tasks:#{key}"
        build_task_from_json json
      end
    end

    def fetch_graph_tasks_from_keys keys
      keys.map do |key|
        json = @redis.get "tasks:#{key}"
        task = build_task_from_json json
        task.comments = fetch_comments_for_task task
        task
      end
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

    def build_comment_from_json json
      hash = JSON.parse json
      hash["author"] = find_user hash["author_id"]
      Comment.new hash
    end

    def members_of key
      @redis.smembers(key) || []
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

      json = {id: user.id, name: user.name, email: user.email, password: user.password}.to_json
      @redis.set "#{key_for(User)}:#{user.id}", json
      @redis.set "users:names:#{user.name}", user.id
    end

    def write_comment comment
      json = {id: comment.id, content: comment.content, author_id: comment.author.id, task_id: comment.task.id}.to_json
      @redis.set "#{key_for(Comment)}:#{comment.id}", json
      @redis.rpush "#{key_for(Task)}:#{comment.task.id}:comments", comment.id
    end

    def set_new_id record
      id = @redis.incr "#{key_for(record.class)}:last_id"
      record.id = id
    end

    def key_for klass
      return "users" if klass == User
      return "tasks" if klass == Task
      return "comments" if klass == Comment
      raise "Unknown klass to serialize (tried to serialize #{klass})"
    end
end
