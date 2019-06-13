json.success true
json.token @token
json.borrowed_book_count @borrowed_book_count
json.user @user, partial: 'api/v1/users/user', as: :user