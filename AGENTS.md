# Rails starter kit

A minimal [Ruby on Rails 8.1](https://rubyonrails.org) app on Ruby 4.0, generated with `rails new --minimal`. It has one controller serving a welcome screen, and one test. It's a starting point: build the app the user asks for on top of it.

## Commands

| Task | Command |
|---|---|
| Install dependencies and prepare the database | `bin/setup --skip-server` |
| Run locally | `bin/rails server -p 3000` |
| Run the tests | `bin/rails test` |
| Lint and check style | `bin/rubocop` |
| Fix style | `bin/rubocop -a` |
| Run the tests, style check, and seeds together | `bin/ci` |

Run `bin/ci` after every change. It must pass.

## Structure

- `config/routes.rb` maps URLs to controllers. `/` goes to `PagesController#home`, which renders `app/views/pages/home.html.erb`, the Laravel Cloud welcome screen, without the layout. Replace it with the app's own home page.
- `app/controllers/`, `app/views/`, and `app/models/` follow Rails conventions. `app/views/layouts/application.html.erb` is the HTML shell.
- `test/` holds Minitest tests. `test/controllers/pages_controller_test.rb` tests the home page.
- `config/ci.rb` defines the steps `bin/ci` runs.

## Conventions

- Follow Rails conventions and use the generators: `bin/rails generate controller`, `model`, `migration`, or `scaffold`. They create the matching tests.
- Keep controllers thin and put logic in models or plain Ruby objects under `app/models/`.
- Style follows `rubocop-rails-omakase`. Don't disable cops to make a change pass.
- Read settings that differ between environments with `ENV.fetch`. This kit has no `config/master.key` or encrypted credentials. Cloud sets `SECRET_KEY_BASE`, so don't add credentials files for secrets Cloud provides.
- Add gems with `bundle add` so `Gemfile.lock` stays in sync, and commit the lockfile. Keep the `aarch64-linux` platforms in `Gemfile.lock`, because Cloud builds on them.
- Active Record must stay. Cloud's deploy command is `bin/rails db:prepare`, which doesn't exist without it.

## On Laravel Cloud

- Cloud detects Rails, installs gems, builds assets with `rails assets:precompile`, runs `bin/rails db:prepare` as the deploy command, and starts the app with `bin/rails server -b '::' -p $PORT`.
- The Ruby version comes from `.ruby-version`, read on every deploy.
- Cloud sets `SECRET_KEY_BASE`, `RAILS_ENV=production`, `RAILS_LOG_TO_STDOUT`, and `APP_URL`. Cloud terminates HTTPS in front of the app, so `assume_ssl` and `force_ssl` are on in production.
- **The database is SQLite, and Cloud's filesystem is ephemeral.** Anything saved is lost on the next deploy or restart. Before the app stores real data, attach a Postgres or MySQL database in Cloud, add the `pg` or `mysql2` gem, and point `production` in `config/database.yml` at `url: <%= ENV["DATABASE_URL"] %>`. Cloud formats `DATABASE_URL` for Rails.

<!-- cloud:start -->

## Laravel Cloud

This app deploys to [Laravel Cloud](https://laravel.com/cloud) with no settings changed. Cloud detects the language and framework from the repository and fills in the build and start commands. Keep the app inside these rules so that stays true.

### Rules

- **Port:** listen on the port in the `PORT` environment variable (3000 if it's unset), on host `::` so both IPv4 and IPv6 connect. Cloud runs nginx on port 8080 in front of the app. Never hard-code a port.
- **Configuration:** read every setting from environment variables. In production Cloud sets them in the process environment; there's no `.env` file. `.env.example` lists what the app reads, for local development only.
- **No Dockerfile:** Cloud builds the image from the repository. Don't add a `Dockerfile`, `docker-compose.yml`, or `Procfile` unless this file says the kit uses one.
- **Ephemeral filesystem:** files written at runtime are lost on every deploy and restart, and replicas don't share them. Store data in a database, cache, or object storage.
- **Scale to zero:** an environment can sleep when idle and wake on the next request. Don't rely on in-memory state or timers in the web process.
- **Versions:** the language version is declared in the repository (see below). Change it there, and only to a version Cloud supports. An unsupported version fails the deploy.

### Adding resources

Attach resources to the environment in Cloud. Cloud injects their connection details as environment variables on the next deploy:

| Resource                   | Variables                                                                                    |
| -------------------------- | -------------------------------------------------------------------------------------------- |
| Postgres or MySQL database | `DATABASE_URL`                                                                               |
| Valkey cache               | `REDIS_URL`                                                                                  |
| Object storage bucket      | `AWS_BUCKET`, `AWS_ENDPOINT_URL`, `AWS_REGION`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` |

The Postgres `DATABASE_URL` ends in a `serverVersion` query parameter. Some drivers reject unknown parameters, so remove it before connecting if the driver complains.

Run background work as a custom worker background process on the environment, with its own command. Run migrations in the environment's deploy command, not at app startup.

### Managing the app

Use the [Laravel Cloud CLI](https://laravel.com/cloud/docs/api/cli) to deploy, read logs, change environment variables, and attach resources. It needs PHP 8.3 or later and Composer. Install it with `composer global require laravel/cloud-cli`, then run `cloud skills:install` to add Laravel Cloud skills to your agent. Run `cloud auth`, or set `LARAVEL_CLOUD_TOKEN` where a browser login isn't possible, and pass `-n` to every command so it never waits for input. A Laravel Cloud MCP server is coming and will cover the same tasks.

Cloud's documentation for agents is at https://laravel.com/cloud/docs/llms.txt, and runtime details are at https://laravel.com/cloud/docs/runtimes.
<!-- cloud:end -->
