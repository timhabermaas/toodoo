$LOAD_PATH.unshift(File.dirname(__FILE__) + "/lib")

require "clients/web/web"

run Sinatra::Application
