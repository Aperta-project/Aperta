FROM ruby:2.4

RUN apt-get update && apt-get install -y \
    libxml2-dev \
    libxslt-dev \
    git \
    libcurl4-openssl-dev \
    imagemagick \
    openssl

RUN mkdir -p /code

WORKDIR /code
RUN gem install bundler -v 1.17.3
COPY Gemfile* /code/
RUN bundle install --path vendor/bundle
COPY . .

EXPOSE 3000

ENV RAILS_ENV=production RACK_ENV=production
CMD ["bundle", "exec", "puma", "-p", "3000"]
