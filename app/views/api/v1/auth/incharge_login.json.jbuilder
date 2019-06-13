json.success true
json.token @token
json.total_book_count @book_count
json.issued_book_count @issued_book_count
json.user @user, partial: 'api/v1/users/user', as: :user