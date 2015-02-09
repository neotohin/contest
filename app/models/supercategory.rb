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

  codes = SUPER_CATEGORIES.keys

  validates :display_name, :presence => true
  validates :letter_code,
            :presence => true,
            :format => {
                :with => /\A(#{codes.join("|")})\z/,
                :message => "only valid codes are #{codes.join(", ")}"
            }
end
