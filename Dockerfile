FROM ruby:3.2.3

RUN apt-get update -qq && apt-get install --no-install-recommends -y \
  build-essential libpq-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN groupadd -r -g 1000 docker && \
useradd -r --create-home -u 1000 -g docker docker

WORKDIR /backend-api

COPY Gemfile /backend-api/Gemfile
COPY Gemfile.lock /backend-api/Gemfile.lock

RUN chown -R docker:docker /backend-api && \
chmod g+w /backend-api/Gemfile.lock

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

USER docker

RUN bundle install

COPY . /backend-api