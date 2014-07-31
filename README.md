# cargobull

A minimal dispatcher library for creating a RESTful service. It comes with a
rack-up integration, a helper for easily creating tests, a setup helper to
autoload folders (that follow naming conventions) or classes with their
respective files directly using the ruby autoload feature and finally an easy
configuration to include the service in irb or any ruby application.

The code and gem is published under the BSD 2-clause license.

# Using cargobull

## Basic configuration with any rack-based server

To get the dispatcher running, a rack-based server (i.e. thin), the gem of
course and a single file containing any CRUD action is required. This may
look similar to:

```ruby
  # filename: config.ru
  require 'cargobull'

  class Bluebeard
    include Cargobull::Service

    # get and post requests
    def read
      return "I can get stuff"
    end

    # put requests
    def create
      return "I can also create stuff"
    end

    # patch requests
    def update
      return "And modify stuff"
    end

    # delete requests
    def delete
      return "And finally delete stuff"
    end
  end

  run Cargobull::Rackup.new
```

Running this will allow these curl calls:

```bash
  curl -X GET localhost:3000/bluebeard
  => I can get stuff

  curl -X POST localhost:3000/bluebeard
  => I can get stuff

  curl -X PUT localhost:3000/bluebeard
  => I can also create stuff

  curl -X PATCH localhost:3000/bluebeard
  => And modify stuff

  curl -X DELETE localhost:3000/bluebeard
  => And finally delete stuff
```

The action for the URL or internal calls (i.e. tests) is always the
class name in underscore notation (Bluebeard becomes bluebeard, BlueBeard
becomes blue_beard, etc.).

## Using the setup file

Putting all classes and logic into one file might not be such a good idea.
Cargobull offers a file that is automatically loaded when found in the
current directory: **setup.rb** which can be used to autoload and require
files. More on naming conventions further down in the README.

```ruby
  # filename: config.ru
  require 'cargobull'
  run Cargobull::Rackup.new
```

```ruby
  # filename: setup.rb
  Cargobull::Initialize.dir "controller"

  # or alternatively
  Cargobull::Initialize.file "Bluebeard", "controller/bluebeard.rb"
```

```ruby
  # filename: controller/bluebeard.rb
  class Bluebeard
    include Cargobull::Service

    # get and post requests
    def read
      return "I can get stuff"
    end

    # put requests
    def create
      return "I can also create stuff"
    end

    # patch requests
    def update
      return "And modify stuff"
    end

    # delete requests
    def delete
      return "And finally delete stuff"
    end
  end
```

Running the modified **config.ru** will require the gem and with that
automatically run the **setup.rb** which includes the **bluebeard.rb**
through either way shown.

## Testing and irb

With the previously created files for the example class, rackup and setup,
you can add a simple test (example with minitest, but rspec or any other works
too)

```ruby
  gem 'minitest'
  require 'minitest/autorun'
  require 'cargobull/test_helper'

  describe Bluebeard do
    it "should dispatch a get request" do
      get :bluebeard, { "i could" => "hand params to it too" }
      assert_equal "I can get stuff", response
    end
  end
```

The test helper will require the gem for you and provides convenience methods
in the module **Cargobull::TestHelper** that is by default included on base.
That means helpers (**get**, **post**, **put**, **patch**, **delete**,
**response**) are available for every describe and after the call make the
result from the dispatcher available to the **response** method. When
the test framework uses classes, just include the test helper into the class
and the methods are available.

Additionally the setup makes the environment available to irb:

```bash
  irb
  irb(main):001:0> require 'cargobull'
  => true
  irb(main):002:0> Cargobull::Dispatch.call(:get, "bluebeard", :my => :param)
  => "I can get stuff"
```

When building a ruby application the interface to the dispatcher is exposed
through **Cargobull::Dispatch.call** which takes the RESTful method, the action
and optional params.
