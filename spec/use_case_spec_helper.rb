require "gateways/in_memory_database"
require "gateways/in_memory_mailer"
require "entities"
require "ostruct"

def database
  @database ||= InMemoryDatabase.new
end

RSpec.configure do |config|
  config.before do
    database.flush
  end
end
