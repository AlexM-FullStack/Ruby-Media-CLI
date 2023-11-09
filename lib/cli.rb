require_relative '../lib/user'
require 'pastel'

class CLI
  def initialize
    @pastel = Pastel.new
    @user = nil
    @selected_media = nil
  end

  def call
    login_or_signup
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

  def login_or_signup
    puts "Enter your username to login: "
    username = gets.chomp
    if User.find_by_name(username)
      @user = User.find_by_name(username)
      puts "Welcome back, #{@user.name}!"
    else
      @user = User.create(name: username)
      puts "#{@user.name} account was successfully created!"
    end
  end

  def main_menu
    input = nil
    until input == 'exit'
      puts " "
      puts @pastel.red.bold('Menu'.upcase)
      puts @pastel.red.bold("===========")
      puts "Type " + @pastel.green('list movies')  + " to see the list of top-rated movies."
      puts "Type " + @pastel.green('list tv shows') + " to see the list of top-rated TV shows"
      puts "Type " + @pastel.cyan('search') + " to search for a movie or TV show by title."
      puts "Type " + @pastel.green('view collection') + " to see your saved movies and TV shows"
      puts "Type " + @pastel.red('remove media') + " to remove a movie or TV show from your collection"
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
      when 'view collection'
        puts " "
        view_collection
      when 'remove media'
        puts " "
        remove_media
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

  def save_media(index, media_collection)
    if index >= 1 && index <= media_collection.length
      selected_media = media_collection[index - 1]
      media_type = selected_media.is_a?(Movie) ? 'Movie' : 'TV Show'

      # Check if media is already in the collection
      if CapturedMedia.exists?(user_id: @user.id, title: selected_media.title, media_type: media_type)
        puts " "
        puts @pastel.red.bold("#{selected_media.title} is already saved in your collection!")
      else
        captured_media = CapturedMedia.new(
          title: selected_media.title,
          overview: selected_media.overview,
          release_date: selected_media.is_a?(Movie) ? selected_media.release_date : selected_media.first_air_date,
          media_type: media_type,
          user_id: @user.id
        )
        if captured_media.save
          puts " "
          puts @pastel.green.bold.underline("#{selected_media.title} successfully saved to your collection!")
        else
          puts @pastel.red.bold.underline("There was an error saving #{selected_media.title} to your collection!")
        end
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
      index = input.to_i
      if index >= 1 && index <= Movie.all.length
        @selected_media = Movie.all[index - 1]
        show_media_details(@selected_media, Movie.all)
        puts " "
        puts "Do you want to save the movie to your collection? (yes/no)"
        save_choice = gets.strip.downcase

        if save_choice == 'yes'
          save_media(index, Movie.all)
        end
      else
        puts " "
        puts "=============================="
        text = "Invalid input. Please enter a valid media number!"
        uppercase_text = text.upcase
        puts @pastel.red.bold(uppercase_text)
      end
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
      puts @pastel.red.bold("Goodbye!")
    else
      index = input.to_i
      if index >= 1 && index <= TVShow.all.length
        @selected_media = TVShow.all[index - 1]
        show_media_details(@selected_media, TVShow.all)
        # Prompt to save a TV show

        puts " "
        puts "Do you want to save the show to your collection? (yes/no)"
        save_choice = gets.strip.downcase

        if save_choice == 'yes'
          save_media(index, TVShow.all)
        end
      end
    end
  end

  def search_media
    puts "  "
    puts @pastel.yellow.bold('Enter a keyword to search for a movie or TV show by title: ')
    puts " "
    keyword = gets.strip.downcase

    matching_media = (Movie.all + TVShow.all).select { |media| media.title.downcase.include?(keyword) }

    if matching_media.empty?
      puts " "
      puts @pastel.red.bold('No movies or TV shows found matching your search!')
      puts " "
    else
      puts " "
      puts @pastel.bold('Movies and TV shows found matching your search:')
      puts ' '
      matching_media.each.with_index(1) do |media, index|
        puts "#{index}. Title: " + @pastel.red.bold(media.title)
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
      puts "Enter a number from search results to save media to your collection or type" + @pastel.red.bold("cancel") + " to go back to main menu" + " or type " + @pastel.red.bold("exit") + " to quit the application"
      choice = gets.strip.downcase

      case choice
        when 'cancel'
          main_menu
        when 'exit'
          puts "============="
          puts @pastel.red.bold("Goodbye !")
        else
        index = choice.to_i
        if index >= 1 && index <= matching_media.length
          save_media(index, matching_media)
        else
          puts @pastel.red.bold("Invalid input. Please enter a valid media number !")
        end
      end
    end
  end

  def show_media_details(media, media_collection)
    index = media_collection.index(media)

    if index
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

  def view_collection
    user_collection = CapturedMedia.where(user_id: @user.id)

    if user_collection.empty?
      puts "Your media collection is empty."
    else
      puts "Your media collection: "
      puts "======================"
      user_collection.each do |item|
        puts "#{item.media_type}: #{item.title}"
      end
    end
  end

  def remove_media
    user_collection = CapturedMedia.where(user_id: @user.id)

    if user_collection.empty?
      puts @pastel.red.bold("Your media collection is empty!")
    else
      displayed_media = user_collection.each.with_index(1).to_a
      puts "Your media collection :"
      puts "======================="

      displayed_media.each do |item, index|
        puts "#{index}. #{item.media_type}: #{item.title}"
      end

      puts " "
      puts "Enter the media number you wish to remove from your collection or type " + @pastel.red.bold("cancel") + " to go back" 
      input = gets.strip.downcase

      if input == 'cancel'
        main_menu
      else
        index = input.to_i
        if index >= 1 && index <= displayed_media.length
          removed_item = displayed_media[index - 1][0]
          removed_item.destroy
          puts @pastel.green.bold("#{removed_item.media_type}: #{removed_item.title} successfully removed from your collection!")
        else
          puts @pastel.red.bold("Invalid input. Please enter a valid number!")
        end
      end
    end
  end
end






















































