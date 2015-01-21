# SL8. The smallest IMDB web application ever

# Remember IMDB gem? Oh, it feels like last year since we used it. Shall we do it again? YES!

# Re-using some knowledge we already have on it, we will implement a small Sinatra web app that performs the following:
# 1. GET '/top250' lists the Top 250 movies names. If a "limit" parameter is set, then we limit the list to first "limit" results.
# 2. GET '/rating' will get the rating for a specific movie or TV show. If "id" is passed, we will use this "id" directly to fetch
# the movie or show. If "name" is passed instead, we will search for that name and get the first result. Also, if the rating is lower than 5,
# we will go to a '/warning' page directly, advising of the dangers of watching that movie/show.
# 3. GET '/info' will get all the information for a specific movie or TV show: name, year of release, cast members... you name it.
# Again, we will use "id" or "name" params to fetch it.
# 4. GET '/results' will get a "term" parameter, and will return the number of results for a search using that term.
# 5. GET '/now' will print the current date and time. Because sometimes it's useful.

require 'sinatra'
require 'sinatra/reloader'
require 'imdb'

set :port, 3000
set :bind, '0.0.0.0'

class Movies

	attr_accessor :title, :director, :rating, :plot_summary

	def show_movies(limit)
		movies = Imdb::Top250.new.movies
		movies[0..limit.to_i-1].map {|movie| movie.title + '<br>'}
	end

	def ratings(query)
		if query.to_i==0
			Imdb::Search.new(query).movies.first.rating.to_s
		else
			Imdb::Movie.new(query).rating.to_s
		end
	end

	def info(movie)
		movie_id = Imdb::Search.new(movie).movies.first.id
		movie = Imdb::Movie.new(movie_id)
		@title = movie.title
		@director =  movie.director[0]
		@rating = movie.rating
		@plot_summary = movie.plot_summary
	end

end

imdb = Movies.new

get '/top250/:limit' do
	imdb.show_movies(params[:limit])
end

get '/ratings/:query' do
	if imdb.ratings(params[:query]).to_i < 5
		redirect("/warning")
	else
		imdb.ratings(params[:query])
	end
end

get '/info/:movie' do
	imdb.info(params[:movie])
	"Title: #{imdb.title} <br>
	 Director: #{imdb.director} <br>
	 Rating: #{imdb.rating} <br>
	 Plot Summary: #{imdb.plot_summary}"
end

get '/warning' do
	'You have bad taste in movies.  Its rating is below 5.'
end


