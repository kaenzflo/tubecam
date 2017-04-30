namespace :heroku do
  desc "This task is called by the Heroku scheduler add-on"
  task crawlftp: :environment do
    puts "Crawl..."
    puts "Job 'Crawl' finished."
  end

end