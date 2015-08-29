require 'sinatra'
require 'json'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'hbjQUnA4zaksWyjrx86y'

helpers do

  def resources
    resources = [
      {singular: "photo", plural: "photos"},
      {singular: "video", plural: "videos"},
      {singular: "book", plural: "books"},
      {singular: "article", plural: "articles"},
      {singular: "post", plural: "posts"},
      {singular: "user", plural: "users"}
    ]
  end

  def choose_resource
    resources[rand(6)]
  end

  def make_route_data_hash(resource)

    data_hash = {
      index: {
        http_verb: "GET",
        path: "/#{resource[:plural]}",
        controller_action: "#{resource[:plural]}#index",
        used_for: "display a list of all #{resource[:plural]}"
      },

      new: {
        http_verb: "GET",
        path: "/#{resource[:plural]}/new",
        controller_action: "#{resource[:plural]}#new",
        used_for: "return an HTML form for creating a new #{resource[:singular]}"
      },

      create: {
        http_verb: "POST",
        path: "/#{resource[:plural]}",
        controller_action: "#{resource[:plural]}#create",
        used_for: "create a new #{resource[:singular]}"
      },

      show: {
        http_verb: "GET",
        path: "/#{resource[:plural]}/:id",
        controller_action: "#{resource[:plural]}#show",
        used_for: "display a specific #{resource[:singular]}"
      },

      edit: {
        http_verb: "GET",
        path: "/#{resource[:plural]}/:id/edit",
        controller_action: "#{resource[:plural]}#edit",
        used_for: "return an HTML form for editing a #{resource[:singular]}"
      },

      update: {
        http_verb: "PATCH/PUT",
        path: "/#{resource[:plural]}/:id",
        controller_action: "#{resource[:plural]}#update",
        used_for: "update a specific #{resource[:singular]}"
      },

      destroy: {
        http_verb: "DELETE",
        path: "/#{resource[:plural]}/:id",
        controller_action: "#{resource[:plural]}#destroy",
        used_for: "delete a specific #{resource[:singular]}"
      }
    }

  end

  def title_row
    title_row = {
      title_0: "HTTP Verb",
      title_1: "Path",
      title_2: "Controller#Action",
      title_3: "Used for"
    }
  end

  def routes
    session[:answer_data].keys
  end

  def col_title_lookups
    session[:answer_data][:index].keys
  end

  def cells
    routes.product(col_title_lookups)
  end

  def create_blank_cells(args)
    to_erase = cells.shuffle![0..(args[:blanks]-1)]
    to_erase.each do |item|
      session[:display_data][item[0]][item[1]] = ""
    end
  end

  def lookup_correct_answer(input)
    route, col = input.split('/')
    session[:answer_data][route.to_sym][col.to_sym]
  end

  def create_cell_id(input)
    '#' + input.delete('/') + '_cell'
  end

  def set_session(args)
    session[:level] = args[:level]
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
  set_session({ level: :normal, blanks: 5 })
  erb :quiz
end

get '/hard' do
  set_session({ level: :hard, blanks: 10 })
  erb :quiz
end

get '/extreme' do
  set_session({ level: :extreme, blanks: 20 })
  erb :quiz
end

get '/chuck_noris' do
  set_session({ level: :chuck, blanks: 27 })
  erb :quiz
end

post '/check_answer' do
  answer_lookup = params['answer_lookup']
  cell_id = create_cell_id(answer_lookup)
  correct_answer = lookup_correct_answer(answer_lookup)
  if params['user_answer'] == correct_answer
    html = '<td class="success">' + correct_answer + '</td>'
    msg = {:correct => true, "cell_id" => cell_id, "html" => html}
  else
    msg = {:correct => false, "cell_id" => cell_id}
  end
  msg.to_json
end

post '/show_answer' do
  answer_lookup = params[:value]
  cell_id = create_cell_id(answer_lookup)
  correct_answer = lookup_correct_answer(answer_lookup)
  html = '<td class="pass">' + correct_answer + '</td>'
  msg = {"cell_id" => cell_id, "html" => html}
  msg.to_json
end
