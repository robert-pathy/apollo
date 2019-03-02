# Base image.
FROM ruby:2.5

# System dependencies for gems.
RUN apt-get update && apt-get install -y \
  nodejs \
  build-essential\
  mysql-client

# Add directory where all application code will live and own it by the web user.
RUN mkdir /app
WORKDIR /app

# Install gems separately here to take advantage of container caching of `bundle install`.
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5

# Add the whole application source to the image and own it all by web:web.
# Note: this is overwritten in development because fig mounts a shared volume at /app.
COPY . ./

# Clean up APT and /tmp when done.
#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Expose default rails port
EXPOSE 3000

ENTRYPOINT ["bundle", "exec"]

# Default command to run when this container is run.
CMD ["rails", "server", "-b", "0.0.0.0"]
