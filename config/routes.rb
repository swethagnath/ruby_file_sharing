Rails.application.routes.draw do
  resources :posts
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: "posts#index"

  resources :posts do
    member do
      post  :shorturl
      post  :private_shorturl
    end
  end
  get '/:shorturl', to: 'posts#getshorturl'
end
