FROM ruby:2.2.4

RUN apt-get update -qq && apt-get install -y build-essential libxml2-dev libxslt1-dev nodejs

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD . $APP_HOME
ENV BUNDLE_JOBS=2
RUN bundle install
