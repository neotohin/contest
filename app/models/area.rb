class Area < ActiveRecord::Base
	has_many :mappings
  has_many :judges, :through => :mappings
  has_many :documents, -> { order "title asc" }, :dependent => :destroy
end
