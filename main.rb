require 'sinatra'
require 'pry'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'hbjQUnA4zaksWyjrx86y'

helpers do

  def make_data_array
    resource_array = [{:singular => "photo", :plural => "photos"},
                      {:singular => "video", :plural => "videos"},
                      {:singular => "book", :plural => "books"},
                      {:singular => "article", :plural => "articles"},
                      {:singular => "post", :plural => "posts"},
                      {:singular => "user", :plural => "users"}]

    resource = resource_array[rand(4)]
    data_array = [["HTTP Verb",  "Path", "Controller#Action", "Used for"],
    ["GET", "/#{resource[:plural]}",  "#{resource[:plural]}#index", "display a list of all #{resource[:plural]}"],
    ["GET", "/#{resource[:plural]}/new", "#{resource[:plural]}#new", "return an HTML form for creating a new #{resource[:singular]}"],
    ["POST", "/#{resource[:plural]}", "#{resource[:plural]}#create", "create a new #{resource[:singular]}"],
    ["GET", "/#{resource[:plural]}/:id", "#{resource[:plural]}#show", "display a specific #{resource[:singular]}"],
    ["GET", "/#{resource[:plural]}/:id/edit", "#{resource[:plural]}#edit", "return an HTML form for editing a #{resource[:singular]}"],
    ["PATCH/PUT", "/#{resource[:plural]}/:id", "#{resource[:plural]}#update", "update a specific #{resource[:singular]}"],
    ["DELETE", "/#{resource[:plural]}/:id", "#{resource[:plural]}#destroy", "delete a specific #{resource[:singular]}"]]
  end

  def get_blanks(number_of_blanks)
    positions = Array (0..27)
    blanks = positions.sample(number_of_blanks)
  end

  def set_session
    session[:data_array] = make_data_array
    session[:correct] = []
    session[:pass] = []
  end
end

get '/' do
  redirect '/normal'
end

get '/normal' do
  set_session
  session[:blanks] = get_blanks(5)
  erb :quiz
end

get '/hard' do
  set_session
  session[:blanks] = get_blanks(10)
  erb :quiz
end

get '/extreme' do
  set_session
  session[:blanks] = get_blanks(20)
  erb :quiz
end

get '/chuck_noris' do
  set_session
  session[:blanks] = get_blanks(27)
  erb :quiz
end

post '/check_answer' do
  id = params['id'].to_i
  answer_array = session[:data_array][1..7]
  correct_answer = answer_array[id/4][id%4]
  if params['answer'] == correct_answer
    session[:blanks].delete(id)
    session[:correct] << id
  end
  erb :quiz
end

post '/show_answer' do
  id = params['id'].to_i
  session[:blanks].delete(id)
  erb :quiz
end
