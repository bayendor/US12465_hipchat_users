require "dotenv"
require "hipchat-api"
require "csv"

Dotenv.load

@client = HipChat::API.new(ENV["HIPCHAT_API"])
@user_list = JSON.parse(@client.users_list.body, object_class: OpenStruct)
@user_emails = @user_list.users.collect(&:email)

def create_user(user_email, user_name)
  @client.users_create(email = user_email, name = user_name, nil, nil, password = "Health911")
end

def update_users(users)
  puts "Working"
  i = 0
  users.each do |row|
    unless @user_emails.include?(row[:email])
      puts "Added: #{row[:first_name]} #{row[:last_name]} - #{row[:email]}"
      create_user(row[:email], "#{row[:first_name]} #{row[:last_name]}")
      i += 1
    end
  end
  puts "Users created: #{i}"
end

input_file = "aetna_denver_directory.csv"

if File.exist? input_file
  contents = CSV.open input_file, headers: true, header_converters: :symbol
  update_users(contents)
else
  puts "File not found"
end
