require 'sinatra'
require 'json'
require "pry"
secret = ENV['RACK_ENV'] == 'test' ? 'somesecret' : ENV['SESSION_SECRET']

use Rack::Session::Cookie, key: 'rack.session',
                           path: '/',
                           secret: secret

RESOURCES = {
  photos: { singular: 'photo', plural: 'photos' },
  videos: { singular: 'video', plural: 'videos' },
  posts: { singular: 'post', plural: 'posts' },
  users: { singular: 'user', plural: 'users' }
}

helpers do
  def choose_resource
    RESOURCES.to_a.sample(1)[0][1]
  end

  def make_route_data_hash(resource)
    {
      index: {
        http_verb: 'GET',
        path: "/#{resource[:plural]}",
        controller_action: "#{resource[:plural]}#index",
        used_for: "display a list of all #{resource[:plural]}"
      },

      new: {
        http_verb: 'GET',
        path: "/#{resource[:plural]}/new",
        controller_action: "#{resource[:plural]}#new",
        used_for: "return an HTML form for creating a new #{resource[:singular]}"
      },

      create: {
        http_verb: 'POST',
        path: "/#{resource[:plural]}",
        controller_action: "#{resource[:plural]}#create",
        used_for: "create a new #{resource[:singular]}"
      },

      show: {
        http_verb: 'GET',
        path: "/#{resource[:plural]}/:id",
        controller_action: "#{resource[:plural]}#show",
        used_for: "display a specific #{resource[:singular]}"
      },

      edit: {
        http_verb: 'GET',
        path: "/#{resource[:plural]}/:id/edit",
        controller_action: "#{resource[:plural]}#edit",
        used_for: "return an HTML form for editing a #{resource[:singular]}"
      },

      update: {
        http_verb: 'PATCH/PUT',
        path: "/#{resource[:plural]}/:id",
        controller_action: "#{resource[:plural]}#update",
        used_for: "update a specific #{resource[:singular]}"
      },

      destroy: {
        http_verb: 'DELETE',
        path: "/#{resource[:plural]}/:id",
        controller_action: "#{resource[:plural]}#destroy",
        used_for: "delete a specific #{resource[:singular]}"
      }
    }
  end

  def title_row
    {
      title_0: 'HTTP Verb',
      title_1: 'Path',
      title_2: 'Controller#Action',
      title_3: 'Used for'
    }
  end

  def routes
    [:index, :new, :create, :show, :edit, :update, :destroy]
  end

  def column_titles
    [:http_verb, :path, :controller_action, :used_for]
  end

  def table_cells
    routes.product(column_titles)
  end

  def create_blank_cells(args)
    cells_to_erase = table_cells.shuffle![0..(args[:blanks] - 1)]
    cells_to_erase.each do |item|
      session[:display_data][item[0]][item[1]] = ''
    end
  end

  def lookup_correct_answer(input)
    route, col = input.split('_', 2)
    session[:answer_data][route.to_sym][col.to_sym]
  end

  def create_cell_id(input)
    '#' + input + '_cell'
  end

  def create_session(args)
    session[:level] = args[:level]
    session[:correct] = 0
    session[:pass] = 0
    session[:blanks] = args[:blanks]
    resource = choose_resource
    session[:display_data] = make_route_data_hash(resource)
    session[:answer_data] = make_route_data_hash(resource)
    create_blank_cells(args)
  end
end

get '/' do
  session.clear
  redirect '/normal'
end

get '/normal' do
  create_session(level: :normal, blanks: 5)
  erb :quiz
end

get '/hard' do
  create_session(level: :hard, blanks: 10)
  erb :quiz
end

get '/extreme' do
  create_session(level: :extreme, blanks: 20)
  erb :quiz
end

get '/chuck_noris' do
  create_session(level: :chuck, blanks: 27)
  erb :quiz
end

get '/answers' do
  resource_lookup = params['resource']
  resource = RESOURCES[resource_lookup.to_sym]
  session[:display_data] = make_route_data_hash(resource)
  session[:level] = :answers
  erb :quiz
end

post '/check_answer' do
  answer_lookup = params['answer_lookup']
  cell_id = create_cell_id(answer_lookup)
  correct_answer = lookup_correct_answer(answer_lookup)
  if params['user_answer'] == correct_answer
    session[:correct] += 1
    html = '<td class="success">' + correct_answer + '</td>'
    msg = {
      correct: true,
      cell_id: cell_id,
      html: html,
      pass_amount: session[:pass],
      correct_amount: session[:correct],
      questions_completed: session[:pass] + session[:correct],
      total_questions: session[:blanks]
    }
  else
    msg = {
      correct: false,
      cell_id: cell_id
    }
  end
  msg.to_json
end

post '/show_answer' do
  session[:pass] += 1
  answer_lookup = params[:value]
  cell_id = create_cell_id(answer_lookup)
  correct_answer = lookup_correct_answer(answer_lookup)
  html = '<td class="pass">' + correct_answer + '</td>'
  msg = {
    cell_id: cell_id,
    html: html,
    pass_amount: session[:pass],
    correct_amount: session[:correct],
    questions_completed: session[:pass] + session[:correct],
    total_questions: session[:blanks]
  }
  msg.to_json
end
