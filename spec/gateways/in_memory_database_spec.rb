require_relative "./shared_database_examples"
require "gateways/in_memory_database"

describe InMemoryDatabase do
  it_behaves_like "a database supporting TooDoo"
end
