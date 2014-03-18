
require_relative "./shared_database_examples"
require "gateways/redis_database"

describe RedisDatabase do
  let(:url) { "redis://localhost:6379/3" }
  subject { RedisDatabase.new(url) }

  before do
    redis = Redis.new url: url
    redis.flushdb
  end

  it_behaves_like "a database supporting TooDoo"
end
