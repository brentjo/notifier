# NotifierAPI

A Rails application that sends SMS messages with a simple POST request:
```bash
curl https://notifierapi.herokuapp.com/c010b0a188a9eec3bc50d84140017290 \
  --header "Content-Type: application/json" \
  --request POST \
  --data '{"message":"Hello world!"}'
```

=>

<img width="432" alt="notifier_text" src="https://user-images.githubusercontent.com/6415223/95006941-abd94480-05be-11eb-9f1b-e190b2c597d2.png">

## Why

Whenever I write one-off scripts and tools, I'll usually want a way for them to send me updates, perferably to my phone via SMS. The easiest way I've found to do this is through email, since many carriers have addresses that forward email to SMS. (E.g Verizon's `your_number@vtext.com`). Instead of re-implementing that email sending logic in every programming language I write a script in, I wrote this app that houses that logic and is invoked via a POST request, since most languages have a standard and simple way to make an HTTP POST request.

I'd recommend deploying this yourself if you wanted to use it for real use cases, but you can check it out live at https://notifierapi.herokuapp.com. Feel free to use junk credentials.

## Setting up local development

Four pieces are needed to run the application:
- PostgreSQL
- Redis
- a `bundle exec rake jobs:work` worker
- the main Rails app

Note: When running locally, sent emails are written to files within the `tmp/mails` directory. If you'd like messages to be sent for real when running locally, the SMTP settings within `config/environments/development.rb` would need to be updated to point to an SMTP server.

**With Docker Compose**

The quickest way to get up and running is via Docker Compose:
```
git clone https://github.com/brentjo/notifier.git
cd notifier
docker-compose build

# Boot up database container for migrations
docker-compose up --detach db

docker-compose run web rake db:create db:migrate

docker-compose up
open http://localhost:3000
```

**Without Docker**

Alternatively, install and run PostgreSQL and Redis manually:
```
brew services start postgres
brew services start redis
```

Create the database locally:
```
bundle exec rake db:create db:migrate
```

Now use `foreman` to spawn the worker and Rails app: (`gem install foreman`)
```
foreman start -f Procfile.dev
```

Or run the two processes yourself:
```
bundle exec unicorn -p 3000 -c ./config/unicorn.rb
# another terminal tab
bundle exec rake jobs:work
```

Open http://localhost:3000

**Database debugging**

To get a Postgres client connected to the database in the container:
```
docker-compose run db psql -h db -U postgres notifier_development
```

Or if not using the Docker Compose setup:
```
psql notifier_development
```

## Running tests

```
docker-compose run web rake test
```

Or if not running within Docker, simply:
```
bundle exec rake test
```

<img src="https://notifierapi.herokuapp.com/" height=0 width=0></img>
