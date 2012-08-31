ADNRuby
=======

A Ruby library for App.net by [@kishyr](https://alpha.app.net/kishyr).

This library follows the current [App.net API Spec](https://github.com/appdotnet/api-spec) (as at 26 August 2012).

### Contributors

ADNRuby is brought to you by these very handsome gentlemen:

* Kishyr Ramdial ([@kishyr](https://alpha.app.net/kishyr))
* Dave Goodchild ([@buddhamagnet](https://alpha.app.net/buddhamagnet))
* Peter Hellberg ([@peterhellberg](https://alpha.app.net/peterhellberg))
* Sebastian Deutsch ([@sippndipp](https://alpha.app.net/sippndipp))

### Installation

Simply add ADNRuby to your Gemfile:

`gem "adnruby"`

Or you can install ADNRuby directly from rubygems.org:

`gem install adnruby`


### Changelog

* **Version 0.3.2** (31 August 2012)
  * Added configuration possibilities to ADN module
  * Implemented convenience methods to retrieve the access token
* **Version 0.3.1** (28 August 2012)
  * Fixed naming conflict
* **Version 0.3** (28 August 2012)
  * Now includes a Post class that describes each post along with a bunch of new methods of accessing a post's replies and the post's original post.
  * Users methods that return user details (follow, unfollow, following, followers, mute, unmute, mute_list) will now return either a User object back, or an array of User objects.
  * Similarly, User methods that return post details (posts, mentions, stream) will return a Post object, or an array of Post objects.
  * To accomplish all this, I've had to change the module structure which will break existing code if you've relied on the modules to access any data. Basically, all modules begin with ADN::API:: now (eg. ADN::API::Post, ADN::API::User).
* **Version 0.2** (27 August 2012)
  * Changed all existing classes to modules and introduced the User class for easily accessing user details
* **Version 0.1** (26 August 2012)
  * Really basic functionality for all existing App.new API methods as per the spec.


### Usage
For API calls that accept parameters described in the App.net API Spec, simply pass them as a dictionary to the method.

```ruby
  require 'adnruby'

  ADN.token = "your App.net OAuth-token here."

  # The easiest way to access a user's data is by initializing the user as an object
  me = ADN::User.new("me") # Parameter can be "me", an integer user ID, or a username.
  me.id
  me.name
  me.username
  me.counts
  me.cover_image
  me.description
  me.avatar_image
  me.created_at

  me.followers    # => Followers as an Array
  me.following    # => Following as Array
  me.posts        # User's posts as an Array
  me.stream       # User's stream as an Array
  me.mentions     # User's mentions as an Array

  me.followers.first.user.username        # The first follower's user's username
  me.following.last.posts.first           # The last user that follows the 'me' user's last post
  me.following.last.posts.first.replies   # Repliest to the last post of the above example's post
  me.mentions.last.user.avatar_image      # The first user that mentioned the 'me' user's avater image
  me.stream.last.html                     # The HTML of the last post in the 'me' user's stream
  me.posts.first.delete                   # Delete the 'me' user's first post

  # Follow another user using their username or user ID
  me.follow "anotheruser"
  me.unfollow 1234

  # Follow another user using their ADN::User object
  another_user = ADN::User.new("anotheruser")
  me.follow another_user
  me.unfollow another_user
  me.mute another_user
  me.unmute another_user
  me.mute_list

  # And access another user's following status relative to yours
  another_user.follows_you
  another_user.is_muted
  another_user.is_following
  # etc ...

  # Posts
  params = { text: "This is an example post on App.net!", reply_to: 189018 }
  post_data = ADN::Post.send(params) # Returns a Post object


  # Alternatively access everying in its raw return format (converted to a Hash) by accessing the
  # ADN::API::User and ADN::API::Post module methods

  # Users
  my_details = ADN::API::User.by_id "me"
  another_user = ADN::API::User.by_id 1234
  # etc...

  # User's stream
  user_stream = ADN::API::Post.stream({ count: 10, include_replies: "true" })

  # Global stream
  global_stream = ADN::API::Post.global_stream
```

Completed documentation will be available soon, but in the meantime you can browse all API methods in `lib/adnruby.rb`.

### OAuth
You can get an access token via OAuth using some convenience methods:

```ruby
  def new
    redirect_to ADN.authorize_url # get the authorization url based on the configuration
  end

  def callback
    data = ADN.get_access_token(params[:code]) # get the access token from the API
    ADN.token = data['access_token'] # set the access token

    if data["error"]
      render :template => 'errors/401'
    else
      user_info = ADN::API::Token.current # use the gem
      ...
    end
  end
```

#### Configuration with Rails
This initializer serves well for easy configuraion via a yml file:

`adb.rb` in `config/initializers`:
```ruby
  File.open(File.join(Rails.root, 'config/adn.yml'), 'r') do |f|
    ADN_CONFIG = YAML.load(f)[Rails.env]
  end

  ADN.configure do |config|
    config.auth_url         = ADN_CONFIG['auth_url']
    config.access_token_url = ADN_CONFIG['access_token_url']
    config.client_id        = ADN_CONFIG['client_id']
    config.client_secret    = ADN_CONFIG['client_secret']
    config.redirect_uri     = ADN_CONFIG['redirect_uri']
    config.scopes           = ADN_CONFIG['scopes']
  end
```

and the correspondig `adb.yml`:
```ruby
  development: &development
    auth_url: https://alpha.app.net/oauth/authenticate
    access_token_url: https://alpha.app.net/oauth/access_token
    client_id: 1234567890
    client_secret: 0987654321
    redirect_uri: http://localhost.img.ly:3000/adn_callback
    scopes:
    - stream
    - email
    - write_post
```

---

### License

**ADNRuby** is licensed under the MIT License and is Copyright (c) 2012 Kishyr Ramdial.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
