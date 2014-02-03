# Hstatic

An HTTP server for you static files

Hstatic is a simple HTTP server for your static files.
It's designed for launching it from anywhere in your filesystem tree.
It features a nice directory listing and automatic publishing of your index.html files

## Features

* Directory listing
* Automatic redirect to index.html
* Port selection with -p cli option
* Remembers the last port used in the published directory
* Checks for other instances running on the same (path, port)

## Installation

Install it with:

    $ gem install hstatic

## Usage

    cd /my/public/files/path
    hstatic

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
