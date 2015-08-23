require 'sinatra'
require 'pry'
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

end

get '/' do
  redirect '/quiz'
end

get '/quiz' do
  @data_array = make_data_array
  erb :quiz
end
