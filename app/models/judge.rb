class Judge < ActiveRecord::Base
	has_many :mappings
  has_many :areas, :through => :mappings
  has_many :documents, -> { order "title asc" }, :dependent => :destroy
end
