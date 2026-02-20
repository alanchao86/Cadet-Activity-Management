FROM ruby:3.2.3-slim

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      libpq-dev \
      nodejs \
      npm \
      postgresql-client && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

RUN chmod +x bin/docker-entrypoint

EXPOSE 3000

ENTRYPOINT ["./bin/docker-entrypoint"]
CMD ["./bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]
