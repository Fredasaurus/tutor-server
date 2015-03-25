namespace :sprint do
  desc 'Sprint 8'
  task :'008pwreal', [:username] => :environment do |t, args|
    require_relative 'sprint_008/pwreal.rb'
    result = Sprint008::PwReal.call

    if result.errors.none?
      puts "Added 'student' user with a practice widget with 5 fake exercises.  " + 
           "Access it with GET /api/courses/#{result.outputs.course.id}/practice.  " +
           "Create a new one with a POST to the same URL."
    else
      result.errors.each{|error| puts "Error: " + Lev::ErrorTranslator.translate(error)}
    end
  end
end
