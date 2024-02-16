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

The app has a docker-compose file, that allows it to run on any machine.
For app to work correctly, docker-compose needs secret master key (which is
secret so it's not shared here), with it's help app can use rails credentials,
which look something like this:

```
secret_key_base: 6ae7189f391e92f2ca14ce9a4ff4bcec26ba373243e1c43aa66f159f6b261a81ac258d8ca02bb343c4d12bfd063654151e50158e49e732786ae4c8b3493f9536
devise_jwt_secret_key: 7efe8ed6df7c12573e591926bb0678b872b1bb1713111db36b442047a4abfaf16c084368d8ccd266721c968085aa04fdb6b19eff8d4580d5444488d1866e2720
```

For CI a github actions workflow is used. It checks if rspec tests
are passing before merging PR to the main branch, to make sure
that there is no unnoticed bugs in the code getting merged.

App uses seeds, to populate database for demonstration purposes,
to access some example user, you can use following credentials:

bernard@executor.com
Password1@

bernard@manager.com
Password1@
