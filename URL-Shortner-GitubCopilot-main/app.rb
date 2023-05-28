require 'sinatra'
require 'securerandom'
require 'active_record'

# Configure the database connection
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'urls.db')

# Create a model for the URL mapping
class URLMapping < ActiveRecord::Base
end

# Homepage route
get '/' do
  erb :index
end

# Shorten URL route
post '/shorten' do
  long_url = params[:url]

  # Check if the long URL already exists in the database
  mapping = URLMapping.find_by(long_url: long_url)

  if mapping
    # If the long URL already exists, display the existing short URL
    short_url = mapping.short_url
  else
    # Generate a unique short URL
    short_url = SecureRandom.hex(4)

    # Store the mapping in the database
    URLMapping.create(short_url: short_url, long_url: long_url)
  end

  # Display the shortened URL
  erb :shortened, locals: { short_url: short_url }
end

# Redirect route
get '/:short_url' do
  short_url = params[:short_url]

  # Retrieve the long URL from the database
  mapping = URLMapping.find_by(short_url: short_url)

  if mapping
    # Redirect to the long URL
    redirect mapping.long_url
  else
    # Handle invalid short URLs
    erb :error
  end
end
