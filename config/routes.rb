Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :auth, only: [] do
        collection do
          post '/signup/staff', to: "auth#signup"
          post '/login/hod', to: "auth#hod_login"
          post '/login/librarian', to: "auth#librarian_login"
          post '/login/incharge', to: "auth#incharge_login"
          post '/login/staff', to: "auth#staff_login"
          get  '/password/forgot', to: "auth#forgot_password"
          post '/password/reset', to: "auth#reset_password"
        end
      end
      resources :books, only: [:index] do
        collection do
          post '/new', to: "books#create"
          post '/search', to: "books#search"
          delete '/delete', to: "books#delete"
        end
      end
    end
  end


end
