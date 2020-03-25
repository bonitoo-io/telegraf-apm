#FROM ruby:2.6.2-stretch
#FROM rubylang/ruby:2.6.3-bionic

FROM ruby:2.6.5-slim-stretch

RUN apt-get update && apt-get install -y \
  curl \
  build-essential \
  libpq-dev &&\
  curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update && apt-get install -y nodejs yarn

# Configure the main working directory. This is the base
# directory used in any further RUN, COPY, and ENTRYPOINT
# commands.
RUN mkdir -p /app
WORKDIR /app
# Copy the Gemfile as well as the Gemfile.lock and install
# the RubyGems. This is a separate step so the dependencies
# will be cached unless changes to one of those two files
# are made.
COPY Gemfile Gemfile.lock ./
#RUN gem install sqlite3 -v '1.4.2' --source 'https://rubygems.org/'
RUN apt update
RUN apt install build-essential sqlite3 libsqlite3-dev yarn -y --no-install-recommends
RUN gem install bundler && bundle install --jobs 20 --retry 5
# Copy the main application.
COPY . ./
# Expose port 3000 to the Docker host, so we can access it
# from the outside.
EXPOSE 3000
# The main command to run when the container starts. Also
# tell the Rails dev server to bind to all interfaces by
# default.
RUN yarn install --check-files
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]