class PublisherMailer < ApplicationMailer

  default :from => %("#{Setting.first.default_person}" <#{Setting.first.default_email}>)

  # add_template_helper(ApplicationHelper)

  def publisher_notification(to_name, to_email, publisher)
    email_code
    @publisher = publisher
    @details = publisher.winning_articles.group_by do |document|
      /([A-Z]{1,2})/.match(document.code)[1]
    end

puts "********************* #{to_name}  -  #{to_email}"
    mail(:to => %("#{to_name}" <#{to_email}>), :subject => Setting.first.email_subject)
  end

  helper_method :get_major, :get_first_name

  def get_major(code)
    Supercategory::SUPER_CATEGORIES[code]
  end

  def get_first_name(name)
    words = name.split(" ")
    words.pop
    words.join(" ")
  end

  def email_code
    @email_code = Digest::MD5.hexdigest("#{Time.now.to_s}-#{self.object_id}")
  end

end
