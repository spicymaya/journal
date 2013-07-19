require 'sinatra'
require 'slim'
require 'sass'
require 'data_mapper'
require 'compass'
require 'dragonfly'
require 'rdiscount'


configure do
	Compass.add_project_configuration(File.join(Sinatra::Application.root, 'config', 'compass.rb'))
end	
DataMapper.setup(:default, ENV['DATABASE_URL'] || 'mysql://root:@127.0.0.1/journal') #find on the website
class Post #model
	include DataMapper::Resource
	property(:id, Serial)
	property(:title, String)
	property(:date, Date)
	property(:body, Text) #stores more text (serial, string, date, text are database types)
	property(:image, String)
end
DataMapper.finalize #just need to do it
DataMapper.auto_upgrade! #create and change the db automatically

#helpers go at the beginning of the file
helpers do
	def protected!
		#password applies on the internet, but not on the computer (ENV-environment)
	    if ENV['RACK_ENV'] == 'production'
	      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
	      unless @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [ENV['username'], ENV['password']]
	        response['WWW-Authenticate'] = %(Basic realm='Administration')
	        throw(:halt, [401, "Not authorized\n"])
	      end
	    end
	 end
	 def markdown(md) 
		RDiscount.new(md, :smart).to_html 
	 end
	 # file is a var that = to params[:image]
	 def img_upload(file)
	 	# puts "++++ #{file.inspect} ++++"
	 	path=File.dirname(__FILE__) + '/public/uploads/' + file[:filename]
	 	# puts "///////"
	 	# puts path
	  	File.open(path, "w") do |upload|
	  		upload.write(file[:tempfile].read)
	   end
	   return file[:filename]
	 end	
end

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
	protected!
	@posts = Post.all(:order => [:date.desc])




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
	@post = Post.get(params[:id].to_i)
	@body_class="edit"
	slim(:form)
end
delete '/posts/:id' do
	post=Post.get(params[:id].to_i)
	post.destroy
	redirect to ('/posts')
end
# patch didn't work cuz ruby is crazzzy or I didn't set it to patch in my form

post '/posts/:id' do
	post=Post.get(params[:id].to_i)
	# post.attributes=params
	# puts params.inspect
	if params[:image]
		img_file=img_upload(params[:image])
		post.image=img_file
	end
	post.title=params[:title]
	post.date=params[:date]
	post.body=params[:body]
	post.save
	redirect to("/posts/#{post.id}")
end	

post '/posts' do
	# params.inspect #params- object which is a hash
	# params["title"] access individual keys/values
	post = Post.new(params) #creates post in memory
	if params[:image] 
		img_file=img_upload(params[:image])
		post.image=img_file
	end
	post.save #writes post to the db
	redirect to('/posts')
end
get '/posts/:id' do # : because var in the route
	#instant variable
	@post = Post.get(params[:id].to_i) #starts with a ":" because it's a symbol type of var, to_i converts a string to an integer
	# @post.inspect
	slim(:detail)
end

# get '/pics' do
# 	@entries = Dir.entries(File.dirname(__FILE__) + '/public/uploads/')
# 	puts "////////////"
# 	puts @entries
# 	# puts @entries[0]
# 	@pictures=@entries.select {|str| str[0]!="."}
# 	slim(:pics)
# end	
