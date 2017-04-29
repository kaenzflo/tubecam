namespace :heroku do
  desc "This task is called by the Heroku scheduler add-on"
  task crawlftp: :environment do
    puts "Create Tubecam..."

    TubecamDevice.create(serialnumber: "testscheduler",
                         user_id: 3,
                         description: "this tubecma is createt by a scheduler",
                         active: true)

    puts "Job 'Create Tubecam' finished."
  end

end