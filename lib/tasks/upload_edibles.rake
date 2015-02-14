require 'csv'

namespace :upload_edibles do
  desc "Upload publishers list to contest app"
  task :publishers, [:file] => :environment do |t, args|
    if args[:file] && File.exists?(args[:file])
      pubs = CSV.read(args[:file], :headers => [:name, :code_number])
      pubs.each do |pub|
        Publisher.create({
                             :name        => pub[:name],
                             :code_number => pub[:code_number]
                         })
      end
    else
      puts "File does not exist. Specify command as \"rake upload_edibles:publishers[<FILE_PATH>]\""
    end
  end
end
