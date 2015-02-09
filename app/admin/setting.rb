ActiveAdmin.register Setting do

  permit_params :list, :of, :attributes, :on, :model, :articles_home,
                :csv_basename, :mail_option, :default_email, :default_person,
                :email_subject, :category_letters

  menu :priority => 8

  actions :show, :edit, :update

  controller do
    def index
      redirect_to(admin_setting_path(Setting.first))
    end
  end

  show :title => "Application Settings" do
    attributes_table do
      row :articles_home
      row :csv_basename
      row :default_person
      row :default_email
      row :email_subject
      row :mail_option do |setting|
        status_tag :mailings_activated, :style => "color: red" if setting.mail_option
        status_tag :mailings_not_activated, :style => "color: black" unless setting.mail_option
      end
      row :category_letters
    end
  end

end
