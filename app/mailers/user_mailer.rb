class UserMailer < ApplicationMailer
  default from: "maths@annauniv.edu"

  def forgot_password(user,token)
    @user = user
    @url = ENV['RESET_LINK'].to_s + "?token=" + token.to_s
    mail(from: 'Department Library <mathsdeptlibrary@gmail.com>', to: @user.email, subject: ENV['FORGOT_SUB'])
  end
end
