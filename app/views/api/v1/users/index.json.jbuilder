json.success true
json.meta do
  json.total_staff @users.total_count
  json.total_pages @users.total_pages
  json.current_page @page.to_i
  json.items_per_page 20
end
json.users @users, partial: 'api/v1/users/user', as: :user
