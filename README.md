# cargobull

A minimal dispatcher library for creating a RESTful service. It comes with a
rack-up integration, a helper for easily creating tests, a setup helper to
autoload folders (that follow naming conventions) or classes with their
respective files directly using the ruby autoload feature and finally an easy
configuration to include the service in irb or any ruby application.

The code and gem is published under the BSD 2-clause license.

# Usage

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
gems. More on naming conventions further down in the README.

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

Running the modified **config.ru** will load the gem and with that
automatically run the **setup.rb** which includes the **bluebeard.rb**
through either way shown.

## Accessing incoming data

Most web applications not only rely on sending data to the client, but also
process incoming data from web forms and the like. This data (GET and POST)
is merged into **@params** automatically and made accessible in the dispatch
class.

```ruby
  # filename: controller/bluebeard.rb
  class Bluebeard
    include Cargobull::Service

    def read
      #return the POST and GET data to the caller
      return @params
    end
  end
```

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


## Serving files

A single page web app that calls data from a web service can either use a
web server to distribute the files which is a bit unhandy in development,
or you can have Cargobull serve it for you.

All files available for serving are located under the folder **files**.
THe default URL for serving is **/files/<any path>** and will by default
attempt to find **index.html** and **index.htm** when requesting a slash.

```ruby
  # filename: setup.rb
  Cargobull.env.dispatch_url = "/api"
```

Assuming a json dispatcher should run under a sub-path like **/api** in the
example above, the file serve URL swaps automatically to **/**.


# Configuration and Options

## Environment options

The environment is exposed through **Cargobull.env**.

### dispatch_url=

The option can be nil or an URL. When nil, files are served from /files
and / dispatches. When an URL is set, files are served from / and the
URL dispatches.

### dispatch_url

Retrieves the current dispatch URL.

### serve_url

Retrieves the current file seerve URL.

### default_files=

Sets the default file names. Default is both index.html and index.htm.
This is an array.

### default_files

Returns the default file names as array.

### transform_in=

Sets a proc taking \*args as argument and expects a return that is afterwards
transformed into an array.

This feature transforms the input params before passing them into the
dispatch class and allowing the CRUD method to access it. Can be used for
parsing incoming JSON for example.

### transform_in

Returns nil or the transformation proc.

### transform_out=

Sets a proc taking one argument and expects a return that is afterwards
offered to the dispatch caller.

This feature transforms the output data before passing them back to the caller.
It can be used to transforming ruby data into JSON.

### transform_out

Returns nil or the transformation proc.

### default_path=

Sets the path that should be returned as default when a request for files
is 404.

### default_path

Returns nil or the default path.

## Autoload options

### Modules and classes

When loading whole directories with subdirectories using
**Cargobull::Initialize.dir** it is possible to nest classes inside modules
as long as the modules are underscore representations of the directory path.

```ruby
  # filename: controllers/good_pirates/bluebeard.rb
  module GoodPirates
    class Bluebeard
    end
  end
```


# Tests

Running the existing test suite for Cargobull is simple. Checkout the master,
navigate into the git root and run:

```bash
  ruby -Ilib test/test_runner.rb
```

