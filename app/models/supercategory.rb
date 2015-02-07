class Supercategory < ActiveRecord::Base

  SUPER_CATEGORIES = {
      "F"  => "BEST FEATURE",
      "S"  => "BEST STORY",
      "R"  => "BEST RECIPE",
      "I"  => "BEST IMAGERY",
      "D"  => "BEST DIGITAL",
      "SI" => "BEST SPECIAL ISSUE (via mail)"
  }

  has_many :categories
end
