base_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(base_dir, "lib")
$LOAD_PATH.unshift(lib_dir)
require "feedcellar/web"

ENV["FEEDCELLAR_HOME"] ||= File.join(base_dir, ".feedcellar")

require "racknga"
require "racknga/middleware/cache"

cache_database_path = File.join(base_dir, "var", "cache", "db")
use Racknga::Middleware::Cache, :database_path => cache_database_path

run Feedcellar::Web
