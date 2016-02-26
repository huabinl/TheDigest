# Mailer for user
class UserMailer < ApplicationMailer
  default from: 'the_digest@example.com'

  def mail_article(art_sent, reciever)
    @greeting = 'Hi'
    reciever = reciever
    @art_sent = art_sent
    mail to: reciever
  end
end
