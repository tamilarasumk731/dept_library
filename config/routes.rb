Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :auth, only: [] do
        collection do
          post '/signup/staff',     to: "auth#signup"
          post '/login/hod',        to: "auth#hod_login"
          post '/login/librarian',  to: "auth#librarian_login"
          post '/login/incharge',   to: "auth#incharge_login"
          post '/login/staff',      to: "auth#staff_login"
          get  '/password/forgot',  to: "auth#forgot_password"
          post '/password/reset',   to: "auth#reset_password"
        end
      end
      resources :books, only: [:index] do
        collection do
          post '/new',      to: "books#create"
          post '/search',   to: "books#search"
          delete '/delete', to: "books#delete"
          post '/edit', to: "books#update"
        end
      end
      resources :users, only: [:index] do
        collection do
          get  '/approve/staff',    to: "users#approve_staff"
          get  '/assign/librarian', to: "users#assign_librarian"
          get  '/assign/incharge',  to: "users#assign_incharge"
          get  '/remove/librarian', to: "users#remove_librarian"
          get  '/remove/incharge',  to: "users#remove_incharge"
          get  '/remove/staff',     to: "users#delete_staff"
          get  '/decline/staff',    to: "users#decline_staff"
          put '/update/staff',     to: "users#update_profile"
        end
      end
    end
  end


end
