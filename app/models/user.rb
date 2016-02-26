# Model for user, a corresponding table is build in database
class User < ActiveRecord::Base
  # Validations
  validates_presence_of :email, :first_name, :last_name, :username, :password, :password_confirmation
  validates_uniqueness_of :username
  validates :email, format: { with: /(.+)@(.+).[a-z]{2,4}/, message: '%{value} is not a valid email' }
  validates :first_name, format: { with: /[A-Za-z]+/, message: '%{value} is not alphabetic' }
  validates :username, length: { minimum: 3, too_short: '%{count} characters is the minimum allowed' }
  validates :password, length: { minimum: 8, too_short: '%{count} characters is the minimum allowed' }
  attr_readonly :username

  # Users can have interests
  acts_as_taggable_on :interests

  # Use secure passwords
  has_secure_password
  has_many :comments

  # Find a user by email, then check the username is the same
  def self.authenticate(username, password)
    user = User.find_by(username: username)
    if user && user.authenticate(password)
      return user
    else
      return nil
    end
  end

  def full_name
    first_name + ' ' + last_name
  end
end
