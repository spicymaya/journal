require 'sinatra'
require 'slim'
require 'sass'
require 'data_mapper'

DataMapper.setup(:default, 'mysql://root:@127.0.0.1/journal')
class Post
	include DataMapper::Resource
	property :id, Serial
	property :title, String
	property :date, Date
	property :body, Text #stores more text (serial, string, date, text are database types)
end
DataMapper.finalize #just need to do it
DataMapper.auto_upgrade! #create and change the db automatically

get '/style.css' do
 scss(:style)
end
get '/hi' do
  "Hello World!"
end
get '/about' do
	slim(:about)
end
get '/info' do
	slim(:info)
end	
get '/posts' do
	@posts = Post.all
	slim(:posts)
end

get '/posts/new' do
	slim(:form)
end
post '/posts' do
	# params.inspect #params- object which is a hash
	# params["title"] access individual keys/values
	post = Post.new(params) #creates post in memory
	post.save #writes post to the db
	redirect '/posts'
end 	
	 

