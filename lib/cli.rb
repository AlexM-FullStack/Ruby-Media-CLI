require 'pastel'

class CLI
    def initialize 
      @pastel = Pastel.new
    end

    def call
      movie_info = API.get_movie_info
      tv_show_info = API.get_tv_shows
      if (movie_info && !movie_info.empty?) && (tv_show_info && !tv_show_info.empty?)
        puts ""
        puts @pastel.blue.bold('Welcome to the Top Rated Movies CLI!'.upcase)
        puts @pastel.blue.bold('=====================================')
        puts ""
        main_menu
      else
        puts @pastel.red.bold("Unable to retrieve movie information. Please check your API key and connection!")
      end
    end
  
    def main_menu
      input = nil
      until input == 'exit'
        puts "Type " + @pastel.green('list movies')  + " to see the list of top-rated movies."
        puts "Type " + @pastel.green('list tv shows') + " to see the list of top rated TV shows"
        puts "Type " + @pastel.cyan('search') + " to search for a movie or TV show by title."
        puts "Type " + @pastel.red('exit') + " to leave the CLI."
        puts " "
        input = gets.strip.downcase
  
        case input
        when 'list movies'
          puts "  "
          list_top_rated_movies
        when 'list tv shows'
          puts "  "
          list_top_rated_tv_shows
        when 'search'
          search_media
        when 'exit'
          puts " ============="
          puts @pastel.red.bold("Goodbye!")
        else
          puts " "
          puts @pastel.red.bold("I don't understand that command. Please try again!".upcase)
          puts " "
        end
      end
    end
  
    def list_top_rated_movies
      puts "Top Rated Movies"
      puts "================"
      Movie.all.each.with_index(1) do |movie, index|
        puts "#{index}. #{@pastel.red.bold(movie.title)}"
      end
  
      puts " "
      puts "-- Enter the number of a movie to see more details, 'menu' to go back, or 'exit' --"
      puts " "
      input = gets.strip.downcase
  
      case input
      when 'menu'
        main_menu
      when 'exit'
        puts "======="
        puts @pastel.red.bold("Goodbye!")
      else
        show_media_details(input, Movie.all)
      end
    end

    def list_top_rated_tv_shows
      puts "Top Rated TV Shows"
      puts "=================="
      TVShow.all.each.with_index(1) do |show, index|
        puts "#{index}. #{@pastel.red.bold(show.title)}"
      end

      puts " "
      puts "-- Enter the number of a TV show to see more details, 'menu' to go back, or 'exit' --"
      puts " "
      input = gets.strip.downcase

      case input
      when 'menu'
        main_menu
      when 'exit'
        puts "========="
        @pastel.red.bold("Goodbye!")
      else
        show_media_details(input, TVShow.all)
      end
    end

    def search_media
      puts "  "
      puts @pastel.yellow.bold('Enter a keyword to search for a movie or TV Show by title: ')
      puts " "
      keyword = gets.strip.downcase
  
      matching_media = (Movie.all + TVShow.all).select { |media| media.title.downcase.include?(keyword) }
  
      if matching_media.empty?
        puts " "
        puts @pastel.red.bold('No movies or TV Shows found matching your search ! ')
        puts " "
      else
        puts " "
        puts @pastel.bold('Movies and TV Shows found matching your search:')
        puts ' '
        matching_media.each.with_index(1) do |media, index|
          puts 'Title: ' + @pastel.red.bold(media.title)
          puts 'Plot summary: ' + @pastel.yellow(media.overview)
          if media.is_a?(Movie)
            puts "Media type -- " + @pastel.red.bold('MOVIE')
            puts "Release Date: " + @pastel.blue(media.release_date)
          elsif media.is_a?(TVShow)
            puts "Media type -- " + @pastel.red.bold('TV SHOW')
            puts "First Air Date: " + @pastel.blue(media.first_air_date)
          end
          puts "========"
          puts " "
        end
      end
    end
  
    def show_media_details(input, media_collection)
      index = input.to_i
      if index >= 1 && index <= media_collection.length
        media = media_collection[index - 1]
        puts " "
        puts " "
        puts "Title: " + @pastel.red.bold(media.title)
        puts "Overview: " + @pastel.yellow.italic(media.overview)
        if media.is_a?(Movie)
          puts "Movie Release Date: " + @pastel.blue(media.release_date)
        elsif media.is_a?(TVShow)
          puts "TV Show First Air Date: " + @pastel.blue(media.first_air_date)
          puts " "
        end
        puts " "
      else
        puts " "
        puts "================================================"
        text = "Invalid input. Please enter a valid media number!"
        uppercase_text = text.upcase
        puts @pastel.red.bold(uppercase_text)
        puts ""
      end
    end
  end
  