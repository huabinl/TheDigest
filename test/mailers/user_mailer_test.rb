require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "mail_article" do
    mail = UserMailer.mail_article
    assert_equal "Mail article", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
