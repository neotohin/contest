class Supercategory < ActiveRecord::Base

  SUPER_CATEGORIES = {
      "F" => "BEST FEATURE",
      "S" => "BEST STORY",
      "R" => "BEST RECIPE",
      "I" => "BEST IMAGERY",
      "SI" => "BEST SPECIAL ISSUE (via mail)"
  }

  has_many :categories
end
