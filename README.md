This is a Ruby on Rails app that allows managers to create teams
and chores, to improve their work efficiency with their executors.

App is devise-jwt, to introduce stateless
and safe standard of user authentication.

Database is PostgreSQL.

For documentation and tests app uses gems rswag and rspec-rails,
which automatically creates documentation and tests
at the same time.

There is also a gem rubocop, which helps in keeping code style
clean and readable.

The app has a docker-compose file, that allows it to run on any machine
(it requires passing rails master key, which is secret),
to make development easier and faster.

For CI a github actions workflow is used. It checks if rspec tests
are passing before merging PR to the main branch, to make sure
that there is no unnoticed bugs in the code getting merged.

App uses seeds, to populate database for demonstration purposes,
to access some example user, you can use following credentials:

bernard@executor.com
Password1@

bernard@manager.com
Password1@
