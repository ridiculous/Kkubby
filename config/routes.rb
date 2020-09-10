Rails.application.routes.draw do
  if Rails.env.production?
    default_url_options protocol: :https, host: 'kkubby.com'
  else
    default_url_options protocol: :http, host: 'localhost:3000'
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get 'login', to: 'sessions#new', as: 'login'
  get 'signin', to: 'sessions#new', as: 'signin'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  post 'login', to: 'sessions#create', as: 'process_login'
  get 'search', to: 'product_search#index', as: 'product_search'
  put 'update_product_order', to: 'product_order#update', as: 'update_product_order'
  scope path: '@:username', as: 'user' do
    resources :shelves do
      resources :products, controller: 'shelf_products'
    end
  end
  get '/@:username', to: 'home#show', as: 'user_home'
  get 'signup', to: 'users#new'
  resources :users, only: :create
  root 'home#index'
end
