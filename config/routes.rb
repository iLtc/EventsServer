Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'events#index', defaults: { format: :json }
  get '/events/categories', to: 'events#categories', defaults: { format: :json }
  get '/events/:eid', to: 'events#detail'
  post '/events/image', to: 'events#upload'

  post '/users', to: 'users#new', defaults: { format: :json }
end
