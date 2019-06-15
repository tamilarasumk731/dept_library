module Api::V1::AuthorUtils
	def update_author_if_needed author_params
		if author_params.present? && author_params[:author_name].present?
		  all_authors = Array.new
		  author_params[:author_name].each do |author|
		    all_authors << Author.find_or_create_by(author_name: author)
		  end
		  all_authors
		else
		  nil
		end
	end
end 