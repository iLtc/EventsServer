Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'events#index', defaults: { format: :json }
  post '/events/', to: 'events#new', defaults: { format: :json }
  get '/events/categories', to: 'events#categories', defaults: { format: :json }
  get '/events/user', to: 'events#user_events', defaults: { format: :json }
  get '/events/:eid', to: 'events#detail'
  post '/events/:eid/like', to: 'events#like', defaults: { format: :json }
  post '/events/:eid/unlike', to: 'events#unlike', defaults: { format: :json }
  post '/events/image', to: 'events#upload', defaults: { format: :json }

  post '/users/new', to: 'users#new', defaults: { format: :json }
end
