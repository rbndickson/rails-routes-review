require 'sinatra'
require 'json'
require 'sinatra/reloader' if development?

secret = ENV['RACK_ENV'] == 'test' ? 'somesecret' : ENV['SESSION_SECRET']

use Rack::Session::Cookie, key: 'rack.session',
                           path: '/',
                           secret: secret

RESOURCES = %w(photo video post user)
COLUMN_TITLES = %w(http_verb path controller_action used_for)
ROUTE_NAMES = %w(index new create show edit update destroy)
LEVEL_TO_BLANK_AMOUNT = { normal: 5, hard: 10, expert: 20, chuck_norris: 27 }

helpers do
  def random_resource
    session[:resource] = RESOURCES.sample
  end

  def resource_data(resource)
    ROUTE_NAMES.each_with_object({}) do |route, obj|
      method = route + '_data'
      obj[route] = route_data(method, resource)
    end
  end

  def route_data(route, resource)
    data = send(route, resource)
    COLUMN_TITLES.each_with_object({}).with_index do |(column_title, obj), i|
      obj[column_title] = data[i]
    end
  end

  def index_data(resource)
    ['GET', "/#{pluralize(resource)}", "#{pluralize(resource)}#index",
     "display a list of all #{pluralize(resource)}"]
  end

  def new_data(resource)
    ['GET', "/#{pluralize(resource)}/new", "#{pluralize(resource)}#new",
     "return an HTML form for creating a new #{resource}"]
  end

  def create_data(resource)
    ['POST', "/#{pluralize(resource)}", "#{pluralize(resource)}#create",
     "create a new #{resource}"]
  end

  def show_data(resource)
    ['GET', "/#{pluralize(resource)}/:id", "#{pluralize(resource)}#show",
     "display a specific #{resource}"]
  end

  def edit_data(resource)
    ['GET', "/#{pluralize(resource)}/:id/edit", "#{pluralize(resource)}#edit",
     "return an HTML form for editing a #{resource}"]
  end

  def update_data(resource)
    ['PATCH/PUT', "/#{pluralize(resource)}/:id", "#{pluralize(resource)}#update",
     "update a specific #{resource}"]
  end

  def destroy_data(resource)
    ['DELETE', "/#{pluralize(resource)}/:id", "#{pluralize(resource)}#destroy",
     "delete a specific #{resource}"]
  end

  def pluralize(input)
    input + 's'
  end

  def table_cells
    ROUTE_NAMES.product(COLUMN_TITLES)
  end

  def display_data(resource)
    cells_to_erase = table_cells.sample(blank_amount)
    data = resource_data(resource)

    cells_to_erase.each_with_object(data) do |(route, column), obj|
      obj[route][column] = ''
    end
  end

  def blank_amount
    LEVEL_TO_BLANK_AMOUNT[params['level'].to_sym]
  end
end

get '/' do
  redirect '/quiz/normal'
end

get '/quiz/:level' do
  @display_data = display_data(random_resource)
  erb :quiz
end

get '/answers/:resource' do
  @display_data = resource_data(params['resource'])
  erb :quiz
end

get '/answers' do
  resource_data(session[:resource]).to_json
end
