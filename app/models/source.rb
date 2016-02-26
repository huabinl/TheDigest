# Model for source, a corresponding table is build in database
class Source < ActiveRecord::Base
  has_many :articles
  validates_uniqueness_of :name
end
