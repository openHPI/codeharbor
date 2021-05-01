FROM ruby:2.3.0

RUN apt-get update -qq && apt-get install -y build-essential

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev
ENV APP_HOME /codeharbor
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN gem install arel -v '6.0.3'
RUN gem install cancancan -v '1.13.1'
RUN gem install mini_portile2 -v '2.0.0'
RUN gem install therubyracer -v '0.12.2'
RUN gem install minitest -v '5.8.3'
RUN gem install mime-types -v '2.99' 
RUN bundle install

EXPOSE 7500

ADD . $APP_HOME
RUN bundle exec rake assets:precompile
CMD bundle exec rails s
