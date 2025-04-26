namespace :db do

  # after db:migrate run this
  task migrate: :environment do
    puts "Run database_consistency - start:"
    puts
    system "bundle exec database_consistency" if Rails.env.development?
    puts
    puts "Run database_consistency - done"
    puts
  end

end
