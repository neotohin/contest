class Judge < ActiveRecord::Base
	has_and_belongs_to_many :areas
  has_many :documents, -> { order "title asc" }, :dependent => :destroy
end
