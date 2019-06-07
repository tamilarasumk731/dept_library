class UserMailer < ApplicationMailer
  default from: "mathsdeptlibrary@gamil.com"

  def forgot_password(user,token)
    @user = user
    @url = ENV['RESET_LINK'].to_s + "?token=" + token.to_s
    mail(from: 'Department Library <mathsdeptlibrary@gmail.com>', to: @user.email, subject: ENV['FORGOT_SUB'])
  end

  def staff_approval(user)
    @user = user
    mail(from: 'Department Library <mathsdeptlibrary@gmail.com>', to: @user.email, subject: ENV['APPROVAL_SUB'])
  end

  def staff_declined(user)
    @user = user
    mail(from: 'Department Library <mathsdeptlibrary@gmail.com>', to: @user.email, subject: ENV['DECLINE_SUB'])
  end

  def profile_update(user)
    @user = user
    mail(from: 'Department Library <mathsdeptlibrary@gmail.com>', to: @user.email, subject: ENV['UPDATE_SUB'])
  end
end
