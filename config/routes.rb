Rails.application.routes.draw do

  resources :api_tokens
  resources :projects
  resources :tasks
  resources :users
  resources :documents
  post '/documents/api_markdown', to: 'documents#api_markdown'
  post '/guest_sign_in' , to: 'sessions#guest_sign_in'

  get '/', to: redirect('/projects')

  get '/auth/:provider/callback', to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
