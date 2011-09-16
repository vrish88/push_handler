PushHandler
===========

PushHandler takes push information and converts it into a format that [Github Services](https://github.com/github/github-services) can read and distribute.

Config
------
1. Download and install [Github Services](https://github.com/github/github-services)
2. Start the Sinatra server by running `ruby github-services.rb`
3. Install the gem `gem install push-handler`
4. In `.git/hooks/` directory of your repository, create a file called `post-receive`.
5. Add the following text to `post-receive`, filling in your information:

```ruby
#!/usr/bin/ruby
require 'rubygems'
require 'push_handler'

# Through STDIN git passes us: <oldrev> <newrev> <refname>
args = STDIN.readlines.first.split(/\s+/)

PushHandler.configure do |config|
  config.repo = {
    # Where to see the repository on the web
    'url' => 'http://git.example.com',

    # Repository name
    'name' => 'Suppa Time',

    # Directory on the machine where the contents of your .git folder lives
    'working_dir' => '/mnt/suppa_time.git/',

    # Repository owner contact info
    'owner' => {
      'name' => 'Big Boss Man',
      'email' => 'bbm@example.com'
    }
  }

  # This is the link to the commit. Put the wildcard '%s' where the commit sha should go.
  config.commit_url = 'http://git.example.com/commits?id=%s'

  # The url that the github-services server is running.
  config.services['url'] = 'http://localhost:8080'

  # This is your configuration for 3rd parties.
  config.services['data'] = {
    'hipchat' => {
      'auth_token' => '9082afake90210',
      'room' => 12345,
      'notify' => true
    }
  }
end

PushHandler.send_to_services(*args)
```

Note
----

To see the parameters that each service requires you'll have to:
1. Go to the `github-services/` directory
2. Execute `rake services:config`
3. Open `config/services.json` and look up the requirements