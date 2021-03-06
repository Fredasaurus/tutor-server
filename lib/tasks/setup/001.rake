namespace :setup do
  desc 'Initializes data for the deployment demo'
  task :'001' => :environment do |tt, args|
    require 'tasks/setup_001'
    result = Setup001.call

    if result.errors.none?
      puts "Success!"
    else
      result.errors.each{ |error| puts "Error: " + Lev::ErrorTranslator.translate(error) }
    end
  end
end
