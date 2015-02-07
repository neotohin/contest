class Category < ActiveRecord::Base
	has_many :mappings
  has_many :judges, :through => :mappings
  has_many :articles, -> { order "title asc" }, :dependent => :destroy
  belongs_to :supercategory
end
