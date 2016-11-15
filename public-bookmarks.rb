require 'sinatra'
require "sinatra/activerecord"
require './models/public_bookmark'
require 'rack-flash'

enable :sessions
use Rack::Flash

helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == [HTTP_BASIC_AUTH['name'], HTTP_BASIC_AUTH['password']]
  end
end


get '/' do
    db_time = database.connection.execute('SELECT CURRENT_TIMESTAMP').first['now']
    request.logger.info "DB time is #{db_time}"
    erb :hello_word
end

get '/public_bookmarks' do
  @public_bookmarks = PublicBookmark.all
  erb :'public_bookmarks/index'
end

get '/public_bookmarks/new' do
  @public_bookmark = PublicBookmark.new
  erb :'public_bookmarks/new'
end

get '/public_bookmarks/:id' do
  @public_bookmark = PublicBookmark.find(params[:id])
  erb :'public_bookmarks/show'
end

post '/public_bookmarks/create' do
  @public_bookmark = PublicBookmark.new(params[:public_bookmark])
  if @public_bookmark.save
    flash[:notice] = 'Public bookmark successfully created!'
    redirect to("public_bookmarks/#{@public_bookmark.id}")
  else
    erb :'public_bookmarks/new'
  end
end
