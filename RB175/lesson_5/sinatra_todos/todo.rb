require "sinatra"
require "sinatra/reloader"
require "sinatra/content_for"
require "tilt/erubis"

configure do
  enable :sessions
  set :session_secret, 'secret'
end

before do
  session[:lists] ||= []
end

helpers do

  # Return a message error if list_name is invalid, otherwise nil.
  def error_for_list_name(name)
    if session[:lists].any? { |list| list[:name] == name }
      "List name must be unique."
    elsif !(1..100).cover? name.strip.size
      "List name must be between 1 and 100 characters."
    end
  end

  def error_for_todo(name)
    if !(1..100).cover? name.strip.size
      "Todo name must be between 1 and 100 characters."
    end
  end

end

get "/" do
  redirect "/lists"
end

# View all the lists
get "/lists" do
  @lists = session[:lists]
  erb :lists, layout: :layout
end

# Render the new list form
get "/lists/new" do
  erb :new_list, layout: :layout
end

# Create a new list
post "/lists" do
  list_name = params[:list_name]

  error = error_for_list_name(list_name)
  if error
    session[:error] = error
    erb :new_list, layout: :layout
  else
    session[:lists] << { name: params[:list_name], todos: [] }
    session[:success] = "The list has been created"
    redirect "/lists"
  end
end

# Displaying a single todo list
get "/lists/:id" do
  @list = session[:lists][params[:id].to_i]
  @list_id = params[:id].to_i
  erb :list, layout: :layout
end

# Edit the list with post
post "/lists/:id" do
  list_name = params[:list_name]
  id = params[:id].to_i
  @list = session[:lists][id]

  error = error_for_list_name(list_name)
  if error
    session[:error] = error
    erb :edit_list, layout: :layout
  else
    @list[:name] = list_name
    session[:success] = "The list has been updated."
    redirect "/lists/#{id}"
  end
end

# Edit the list
get "/lists/:id/edit" do
  @list = session[:lists][params[:id].to_i]
  erb :edit_list, layout: :layout
end

# Delete a todo list
post "/lists/:id/destroy" do
  id = params[:id].to_i
  session[:lists].delete_at(id)
  session[:success] = "The list has been deleted."
  redirect "/lists"
end

# Add a todo to the list
post "/lists/:list_id/todos" do
  @list_id = params[:list_id].to_i
  @list = session[:lists][@list_id]
  text = params[:todo].strip

  error = error_for_todo(text)
  if error
    session[:error] = error
    erb :list, layout: :layout
  else
    @list[:todos] << {name: text, completed: false}
    session[:success] = "The todo was added."
    redirect "/lists/#{@list_id}"
  end
end

# Delete a todo from a list
post "/lists/:list_id/todos/:id/destroy" do
  @list_id = params[:list_id].to_i
  @list = session[:lists][@list_id]
  todo_id = params[:id].to_i

  @list[:todos].delete_at(todo_id)
  session[:success] = "The todo has been added."
  redirect "/lists/#{@list_id}"
end

# Mark or unmark a todo from a list
post "/lists/:list_id/todos/:id" do
  @list_id = params[:list_id].to_i
  @list = session[:lists][@list_id]
  todo_id = params[:id].to_i

  boolean_complete = params[:completed] == "true"
  @list[:todos][todo_id][:completed] = boolean_complete

  session[:success] = "The todo has been updated."
  redirect "/lists/#{@list_id}"
end
