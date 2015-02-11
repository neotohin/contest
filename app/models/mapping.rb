class Mapping < ActiveRecord::Base
  belongs_to :category
  belongs_to :judge

  validate :choices_dont_match?

  def choices_dont_match?
    return if first_choice.nil? || second_choice.nil?
    if first_choice == second_choice
      errors.add(:first_choice, "can't equal second choice")
      errors.add(:second_choice, "can't equal first choice")
    end
  end

end