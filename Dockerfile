FROM ruby:2.7.6

RUN apt-get update -qq && apt-get install -y build-essential

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev
ENV APP_HOME /codeharbor
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install

EXPOSE 7500

ADD . $APP_HOME
RUN bundle exec rake assets:precompile
CMD bundle exec rails s
