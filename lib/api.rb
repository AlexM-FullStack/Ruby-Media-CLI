require 'pry'
require 'dotenv/load'

require 'json'
require 'net/http'

class API
  def self.get_movie_info
    url = "https://api.themoviedb.org/3/movie/popular?language=en-US&api_key=a76f0d2654ade11210a1f5ac8b5129a7"
    uri = URI(url)
    response = Net::HTTP.get(uri)
    movie_info = JSON.parse(response)["results"]
    #array displays movie titles
    movie_titles = []

    movie_info.each do |data|
        title = data["title"]
        overview = data["overview"]
        release_date = data["release_date"]
        Movie.new(title, overview, release_date)
        movie_titles << title
    end
    movie_titles
  end

  def self.get_tv_shows
    url = "https://api.themoviedb.org/3/trending/tv/day?language=en-US&api_key=a76f0d2654ade11210a1f5ac8b5129a7"
    uri = URI(url)
    response = Net::HTTP.get(uri)
    tv_show_info = JSON.parse(response)["results"]
    tv_show_titles = []

    tv_show_info.each do |data|
        title = data["name"]
        overview = data["overview"]
        first_air_date = data["first_air_date"]
        TVShow.new(title, overview, first_air_date)
        tv_show_titles << title
    end
    tv_show_titles
  end

end

class Movie
    attr_accessor :title, :overview, :release_date
    @@all = []
    def initialize(title, overview, release_date)
        @title = title
        @overview = overview
        @release_date = release_date
        @@all << self
    end

    def self.all
        @@all
    end

    def display_movie_information
        puts "Title: #{title}"
        puts "Overview: #{overview}"
        puts "Release Date: #{release_date}"
    end
end

class TVShow
    attr_accessor :title, :overview, :first_air_date
    @@all = []
    def initialize(title, overview, first_air_date)
        @title = title
        @overview = overview
        @first_air_date = first_air_date
        @@all << self
    end
    def self.all
        @@all
    end
    def display_tv_show_information
        puts "Title: #{title}"
        puts "Overview: #{overview}"
        puts "First Air Date: #{first_air_date}"
    end
end