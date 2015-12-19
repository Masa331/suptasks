require 'dotenv'
Dotenv.load!('.production')

require File.expand_path('../suptasks', __FILE__)
run Suptasks.app
