json.success true
json.token @token
if @user.role == 'HoD'
  json.staff_count @staff_count
  json.total_book_count @book_count
  json.issued_book_count @issued_book_count
  json.new_book_count @new_book_count
elsif @user.role == 'Librarian'
  json.staff_count @staff_count
  json.total_book_count @book_count
  json.issued_book_count @issued_book_count
elsif @user.role == 'Incharge'
  json.total_book_count @book_count
  json.issued_book_count @issued_book_count
else
  json.borrowed_book_count @borrowed_book_count
end
json.user @user, partial: 'api/v1/users/user', as: :user