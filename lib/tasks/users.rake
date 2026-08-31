namespace :users do
  desc "Print a user's API token (EMAIL defaults to admin@localhost)"
  task api_token: :environment do
    email_address = ENV.fetch("EMAIL", "admin@localhost")
    user = User.find_by(email_address: email_address)

    abort "No user found with email address #{email_address.inspect}" unless user

    puts user.api_token
  end
end
