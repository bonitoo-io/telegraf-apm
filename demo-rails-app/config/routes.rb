Rails.application.routes.draw do
  resources :posts

  get 'error/error'
  get 'welcome/index'
  root :to => 'posts#index'

  # root 'welcome#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
