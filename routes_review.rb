require 'sinatra'
require 'json'

secret = ENV['RACK_ENV'] == 'test' ? 'somesecret' : ENV['SESSION_SECRET']

use Rack::Session::Cookie, key: 'rack.session',
                           path: '/',
                           secret: secret

RESOURCES = %w(photo video post user)

helpers do
  def random_resource
    RESOURCES.sample
  end

  def resource_data(resource)
    {
      index: route_data(:index_data, resource),
      new: route_data(:new_data, resource),
      create: route_data(:create_data, resource),
      show: route_data(:show_data, resource),
      edit: route_data(:edit_data, resource),
      update: route_data(:update_data, resource),
      destroy: route_data(:destroy_data, resource)
    }
  end

  def route_data(route, resource)
    data = send(route, resource)
    {
      http_verb: data[0],
      path: data[1],
      controller_action: data[2],
      used_for: data[3]
    }
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
    column_titles = [:http_verb, :path, :controller_action, :used_for]
    routes = [:index, :new, :create, :show, :edit, :update, :destroy]
    routes.product(column_titles)
  end

  LEVEL_TO_BLANKS = { normal: 5, hard: 10, expert: 20, chuck_noris: 27 }

  def display_data(resource)
    cells_to_erase = table_cells.sample(blanks)
    data = resource_data(resource)

    cells_to_erase.each_with_object(data) do |(route, col), obj|
      obj[route][col] = ''
    end
  end

  def correct_answer(input)
    route, col = input.split('_', 2)
    session[:answer_data][route.to_sym][col.to_sym]
  end

  def create_cell_id(input)
    '#' + input + '_cell'
  end

  def create_session
    session.clear
    session[:blanks] = blanks
    session[:correct] = 0
    session[:pass] = 0
    resource = random_resource
    session[:answer_data] = resource_data(resource)
    session[:display_data] = display_data(resource)
  end

  def blanks
    LEVEL_TO_BLANKS[params['level'].to_sym]
  end

  def message(cell_id, html)
    {
      cell_id: cell_id,
      html: html,
      pass_amount: session[:pass],
      correct_amount: session[:correct],
      questions_completed: session[:pass] + session[:correct],
      total_questions: session[:blanks]
    }
  end
end

get '/' do
  redirect '/quiz/normal'
end

get '/quiz/:level' do
  create_session
  erb :quiz
end

get '/answers/:resource' do
  session[:display_data] = resource_data(params['resource'])
  erb :quiz
end

post '/check_answer' do
  question = params['question']
  cell_id = create_cell_id(question)
  correct_answer = correct_answer(question)

  if params['user_answer'] == correct_answer
    session[:correct] += 1
    html = "<td class='success' id='#{cell_id[1..-1]}'>" + correct_answer + '</td>'
    msg = message(cell_id, html).merge!(correct: true)
  else
    msg = { correct: false, cell_id: cell_id }
  end

  msg.to_json
end

post '/show_answer' do
  session[:pass] += 1
  question = params[:value]
  cell_id = create_cell_id(question)
  correct_answer = correct_answer(question)
  html = "<td class='pass' id='#{cell_id[1..-1]}'>" + correct_answer + '</td>'
  msg = message(cell_id, html)
  msg.to_json
end
