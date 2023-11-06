require 'pry'
require 'httparty' 
require 'json'
require 'active_record'

require_relative '../lib/cli'
require_relative '../lib/api'
# MOVIE_DB_API_KEY = 'a76f0d2654ade11210a1f5ac8b5129a7'


ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => './config/media.db'
)