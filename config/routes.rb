Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'my_application_sessions' }
end