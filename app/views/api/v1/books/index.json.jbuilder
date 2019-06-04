json.success true
json.meta do
  json.total_books @books.total_count
  json.total_pages @books.total_pages
  json.current_page @page.to_i
  json.items_per_page 20
end
json.books @books, partial: 'api/v1/books/book', as: :book
