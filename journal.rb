require 'sinatra'
require 'slim'
require 'sass'
require 'data_mapper'
require 'compass'


configure do
	Compass.add_project_configuration(File.join(Sinatra::Application.root, 'config', 'compass.rb'))
end	
DataMapper.setup(:default, 'mysql://root:@127.0.0.1/journal') #find on the website
class Post #model
	include DataMapper::Resource
	property(:id, Serial)
	property(:title, String)
	property(:date, Date)
	property(:body, Text) #stores more text (serial, string, date, text are database types)
end
DataMapper.finalize #just need to do it
DataMapper.auto_upgrade! #create and change the db automatically

#doing the job of controllers; .slim files are views
get '/style.css' do
 scss(:style)
end

get '/' do
	@body_class = "home"
 	slim(:index)
end
# get '/about' do
# 	slim(:about)
# end

get '/posts' do
	@posts = Post.all

	slim(:posts)
end

get '/posts/new' do
	protected!
	@post=Post.new
	@body_class="new"
	slim(:form)
end
get '/posts/:id/edit' do
	protected!
	@post = Post.get(params[:id])
	@body_class="edit"
	slim(:form)
end
delete '/posts/:id' do
	post=Post.get(params[:id])
	post.destroy
	redirect to ('/posts')
end
# patch didn't work cuz ruby is crazzzy or I didn't set it to patch in my form
post '/posts/:id' do
	post=Post.get(params[:id])
	# post.attributes=params
	# puts params.inspect
	post.title=params[:title]
	post.date=params[:date]
	post.body=params[:body]
	post.save
	redirect to ("/posts/#{post.id}")
end	

post '/posts' do
	# params.inspect #params- object which is a hash
	# params["title"] access individual keys/values
	post = Post.new(params) #creates post in memory
	post.save #writes post to the db
	redirect to ('/posts')
end
get '/posts/:id' do # : because var in the route
	#instant variable
	@post = Post.get(params[:id]) #starts with a ":" because it's a symbol type of var, to_i converts a string to an integer
	slim(:detail)
end
post '/pics/upload' do 
	# puts "//////////////"
	# puts params['myfile'][:tempfile]
	path=File.dirname(__FILE__) + '/public/uploads/' + params['myfile'][:filename]
	# puts "///////"
	# puts path
  File.open(path, "w") do |upload|
  	upload.write(params['myfile'][:tempfile].read)
  end	
  redirect to ('/pics')
end
# class String
# 	def initial
#     self[0,1]
#   end
# end

get '/pics' do
	@entries = Dir.entries(File.dirname(__FILE__) + '/public/uploads/')
	puts "////////////"
	puts @entries
	# puts @entries[0]
	@pictures=@entries.select {|str| str[0]!="."}
	slim(:pics)
end	

helpers do
	def protected!
		#password applies on the internet, but not on the computer (ENV-environment)
	    if ENV['RACK_ENV'] == 'production'
	      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
	      unless @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ["MAYA", "123"]
	        response['WWW-Authenticate'] = %(Basic realm='Administration')
	        throw(:halt, [401, "Not authorized\n"])
	      end
	    end
	 end
end
