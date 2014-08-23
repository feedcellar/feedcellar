base_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(base_dir, "lib")
$LOAD_PATH.unshift(lib_dir)
require "feedcellar/web"

ENV["FEEDCELLAR_BASE_DIR"] ||= File.join(base_dir, ".feedcellar")

run Feedcellar::Web
