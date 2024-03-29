Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :auth, only: [] do
        collection do
          post '/signup/staff',     to: "auth#signup"
          post '/login',            to: "auth#login"
          get  '/password/forgot',  to: "auth#forgot_password"
          post '/password/reset',   to: "auth#reset_password"
          get  '/authorize',        to: "auth#authorize_token"
        end
      end
      resources :books, only: [:index] do
        collection do
          post '/new',      to: "books#create"
          post '/search',   to: "books#search"
          delete '/delete', to: "books#delete"
          put '/edit',      to: "books#update"
          post '/batch_create', to: "books#batch_create"
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
          put  '/update/staff',     to: "users#update_profile"
          get  '/profile',          to: "users#user_info"
          get  '/dashboard',        to: "users#dashboard"
        end
      end

      resources :transactions, only: [] do
        collection do
          get '/issue',               to: "transactions#issue_book"
          get '/return',              to: "transactions#return_book"
          get '/staff/returned_list', to: "transactions#specific_returned_list"
          get '/staff/issued_list',   to: "transactions#specific_issued_list"
          get '/issued_list',         to: "transactions#issued_list"
          get '/returned_list',       to: "transactions#returned_list"
        end
      end

    end
  end
end
