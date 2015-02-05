class JudgeMailer < ApplicationMailer

  default :from => %("#{Setting.first.default_person}" <#{Setting.first.default_email}>)

  add_template_helper(ApplicationHelper)

  def contest_notification(to_name, to_email, judge)
    @judge = judge
    @details = judge.documents.group_by(&:area_id)

    mail(:to => %("#{to_name}" <#{to_email}>), :subject => Setting.first.email_subject)
  end

end
