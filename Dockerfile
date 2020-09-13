FROM ruby:2.6.6
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
RUN mkdir /notifier
WORKDIR /notifier

COPY Gemfile /notifier/Gemfile
COPY Gemfile.lock /notifier/Gemfile.lock
COPY vendor /notifier/vendor

RUN gem install bundler:2.0.1
RUN bundle install

COPY . /notifier

EXPOSE 3000

# Start the main process
CMD ["bundle", "exec", "unicorn", "-p", "3000", "-c", "./config/unicorn.rb"]
