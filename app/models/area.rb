class Area < ActiveRecord::Base
	has_and_belongs_to_many :judges
  has_many :documents, -> { order "title asc" }, :dependent => :destroy
end
