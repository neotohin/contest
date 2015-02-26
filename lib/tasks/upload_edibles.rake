require 'csv'

namespace :upload_edibles do
  desc "Upload publishers list to contest app"
  task :publishers, [:file] => :environment do |t, args|
    if args[:file] && File.exists?(args[:file])
      pubs = CSV.read(args[:file], :headers => [:name, :contact, :email, :code_number])
      Publisher.destroy_all
      pubs.each do |pub|
        p             = Publisher.new
        p.name        = pub[:name]
        p.code_number = pub[:code_number]
        p.publisher_contact = pub[:contact]
        p.publisher_email   = pub[:email]
        p.save!
        puts "Creating #{pub[:name]}, code #{pub[:code_number]}"
      end
      Article.all.each do |article|
        pub = Publisher.where(:code_number => article.publisher_number).first
        puts "Indexing #{article.pretty_title} with publisher '#{pub.try(:name)}'"
        article.publisher_id = Publisher.where(:code_number => article.publisher_number).first.try(:id)
        article.save!
      end
    else
      puts "File does not exist. Specify command as \"rake upload_edibles:publishers[<FILE_PATH>]\""
    end
  end

end
