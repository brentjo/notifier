Rails.application.routes.draw do

  root 'dashboard#show'

  # Registration routes
  get '/register' => 'users#new'
  post '/users' => 'users#create'

  # Login routes
  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  post '/logout' => 'sessions#destroy'

  # Notification routes
  get '/notifications/new' => 'notifications#new'
  post '/notifications' => 'notifications#create'
  get '/notifications' => 'notifications#show'
  delete '/notifications' => 'notifications#destroy'
  post '/notifications/test' => 'notifications#send_test_notification'


  # Routes for the that users POST data to through the random token value
  post "/:token" => "notifications#send_notification", :constraints => {:token => /[0-9a-f]{32}/}

  # Catch all
  match "*path", to: "dashboard#error", via: :all

end
