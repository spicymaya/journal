require 'sinatra'
require 'slim'
require 'sass'

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
get '/form' do
	slim(:form)
end

