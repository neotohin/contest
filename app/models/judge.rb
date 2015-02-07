class Judge < ActiveRecord::Base
	has_many :mappings
  has_many :categories, :through => :mappings
  has_many :articles, -> { order "title asc" }, :dependent => :destroy
end
