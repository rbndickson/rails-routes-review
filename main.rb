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
                      {:singular => "article", :plural => "articles"}]

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

  def get_blanks_index
    positions = Array (0..27)
    blanks = positions.sample(5)
  end
end

get '/' do
  redirect '/quiz'
end

get '/quiz' do
  session[:data_array] = make_data_array
  session[:blanks] = get_blanks_index
  erb :quiz
end

post '/check_answer' do
  id = params['id'].to_i
  answer_array = session[:data_array][1..7]
  correct_answer = answer_array[id/4][id%4]
  session[:blanks].delete(id) if params['answer'] == correct_answer
  erb :quiz
end

post '/show_answer' do
  id = params['id'].to_i
  session[:blanks].delete(id)
  erb :quiz
end
