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

    # get requests
    def read(params)
      return "I can get stuff"
    end

    # post requests
    def create(params)
      return "I can also create stuff"
    end

    # put and patch requests
    def update(params)
      return "And modify stuff"
    end

    # delete requests
    def delete(params)
      return "And finally delete stuff"
    end
  end

  run Cargobull.runner
```

The return value will automatically be wrapped into a rack-compatible
response with the code 200 and a default content-type. Optional post
and get parameters will be made available through an argument inside
the CRUD method.

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
becomes blue_beard, etc.) and modules are separated by slash
(Pirate::Bluebeard becomes pirate/bluebeard).

## Using the setup file

Putting all classes and logic into one file might not be such a good idea.
Cargobull offers a file that is automatically loaded when found in the
current directory: **setup.rb** which can be used to autoload and require
gems. More on naming conventions further down in the README.

```ruby
  # filename: config.ru
  require 'cargobull'
  run Cargobull.runner
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

    def read(params)
      return "I can get stuff"
    end

    def create(params)
      return "I can also create stuff"
    end

    def update(params)
      return "And modify stuff"
    end

    def delete(params)
      return "And finally delete stuff"
    end
  end
```

Running the modified **config.ru** will load the gem and with that
automatically run the **setup.rb** which includes the **bluebeard.rb**.

## Accessing incoming data

Most web applications not only rely on sending data to the client, but also
process incoming data from web forms and the like. This data (GET and POST)
is merged into **params** argument automatically and made accessible in the
dispatch class. Please note that the **params** are passed along by rack,
keys and values will most likely be Strings.

```ruby
  # filename: controller/bluebeard.rb
  class Bluebeard
    include Cargobull::Service

    # params: a hash of transmitted data
    def read(params)
      #return the POST or GET data to the caller
      return params.inspect
    end
  end
```

Incoming content types determine the processing of the form data. If the
content type is **x-www-form-urlencoded** rack will automatically preprocess
the data into a hash. If the content type is anything else, the body is
stored as **body: StringIO**. The StringIO object is made available by rack
and can be read from. The **params** will include the body via the body key.

## Testing and irb

With the previously created files for the example class, rackup and setup,
you can add a simple test (example with minitest, but rspec or any other works
too)

```ruby
  gem 'minitest'
  require 'minitest/autorun'
  require 'cargobull/test_helper'

  describe Bluebeard do
    before do
      @env = Cargobull.env.get
    end

    it "should dispatch a get request" do
      get @env, :bluebeard, { "i can" => "hand params to it too" } do |r|
        assert_equal [200, { "Content-Type" => "text/plain" },
          "I can get stuff"], r
      end
    end
  end
```

The test helper will require the gem for you and provides convenience methods
in the module **Cargobull::TestHelper** that is by default included on base.
That means helpers (**get**, **post**, **put**, **patch**, **delete**) are
available for every describe and after the call make the result from the
dispatcher available to a block if available or as a return value from the
helper call. When the test framework uses classes, just include/extend the
test helper into the class and the methods are available.

Additionally the setup makes the environment available to irb:

```bash
  irb
  irb(main):001:0> require 'cargobull'
  => true
  irb(main):002:0> Cargobull::Dispatch.call(Cargobull.env.get, "GET",
    "bluebeard", my: "param")
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
The default URL for serving is **/files/<any path>** and will by default
attempt to find **index.html** and **index.htm** when requesting a slash.

To setup the file serving prefix, use the **file_url** option in the
environment.

# Configuration and Options

A multitude of options are available through the environment and are
usually filled with a default value. Manually setting them is possible
but needs to happen before rack is initialized.

```ruby
  # filename: config.ru
  require 'cargobull'

  env = Cargobull::Env.update(Cargobull.env.get, :dispatch_url, "/api2",
    :ctype, "application/json")
  run Cargobull.runner(env)
```

or in an alternative style

```ruby
  # filename: config.ru
  require 'cargobull'

  env = Cargobull::Env.update(Cargobull.env.get,
    { dispatch_url: "/api2", ctype: "application/json" })
  run Cargobull.runner(env)
```

The environment is a hash and can also be updated by merge or via key.
Be aware that the environment is frozen once it is passed into the
runner.

The environment has these default settings:

```ruby
  DEFAULTS = {
    dispatch_url: "/api",
    file_url: "/",
    default_files: ["index.html", "index.htm"],
    default_path: nil,
    ctype: "text/plain",
    e403: "Forbidden",
    e404: "Not found",
    e405: "Method not allowed",
    e500: "Internal error",
    transform_out: nil,
    transform_in: nil
  }
```

## Environment options

The environment is exposed through **Cargobull.env.get**.

### dispatch_url

The option is an URL. This is the URL prefix after which all registered
services are available. So if your dispatch_url is "/api" and you have
a service class called Bluebeard, the url to reach it is "/api/bluebeard".

### serve_url

The option is an URL. This is the URL prefix for dipatching plain files,
for instance the index.html. Locally the files are stored in the project
folder under **./files/** by convention.

### default_files

Sets the default file names. Default is both index.html and index.htm.
This is a first match array. This option is used when calling the serve_url
without a file.

### ctype

This is the default content type for the rack header when dispatching errors
and return values from the service class. Use transform_out when the service
class should return a different content type.

### e403, e404, e405 and e500

These are strings used when an error occurs inside the framework.

### transform_in

This proc processes incoming params. Especially useful when the payload is
json.

As a sidenote, the proc takes all arguments passed as params into the
**Cargobull::Dispatch.call** method. For the rack server, this is a hash.
Other servers building on Cargobull may pass in more data.

This method must return an array of all arguments.

### transform_out

This proc processes return data. Especially useful when the payload should
be json, yet the service class returns ruby objects.

Please note that the proc can either return a rack-compatible response
as an array of 3 elements, or a simple string response, which will be
wrapped into a successful http code with the default content type in
the header.

### default_path

Sets the path that should be returned as default when a request for files
is 404. When building a single-page application it may be sensible to always
return the index and let the javascript handle the routing.

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

The **Cargobull::Initialize.file** alternative supports the same module
nesting capabilities.


# Example

In the example folder you find a full example including a react.js-based
comsumer of the created web service. You can run it with any rack-based
webserver installed, for instance thin. The example has a dependency
on **json** and **redis**, you should install both gems before trying
to run it.

```bash
  git clone git@github.com:matthias-geier/cargobull
  cd cargobull/example
  thin start
```

Navigate to the host and port of the service, usually **localhost:3000**
in your web browser and you will be able to see the web service in action.


# Tests

Running the existing test suite for Cargobull is simple. Checkout the master,
navigate into the git root and run:

```bash
  ruby -Ilib test/test_runner.rb
```

