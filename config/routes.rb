Securesign::Application.routes.draw do
  resources :users
  resources :sessions
  
  get 'logout' => 'sessions#destroy', as: 'logout'
  get 'login' => 'sessions#new', as: 'login'
  post 'login' => 'sessions#create', as: 'sessions'
  post 'users/:id' => 'users#destroy'
  get 'signup' => 'users#new', as: 'signup'

  root to: 'info#index'
end
