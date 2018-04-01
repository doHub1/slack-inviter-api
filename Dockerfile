FROM ruby:2.5.1
MAINTAINER knjcode <knjcode@gmail.com>
WORKDIR /usr/src/app
COPY Gemfile* ./
RUN bundle install
COPY . .
CMD ["rails", "server", "-b", "0.0.0.0"]
