Provisional
===========

Provisional is a tool to manage and provision server images.
It is designed to make building immutable servers easier,
by automating the process of image creation.

Images are created based on other images (such as an AWS AMI).
You define scripts that are run to install and configure any required software.

You can then provision your images to deploy your application.

Provisional currently works only with Digital Ocean,
but can easily be extended to work with other providers.


## Installation

You'll need Ruby (2.0 or later) installed on your local system.

Install Provisional with Rubygems:

~~~ bash
gem install provisional
~~~


## Usage

Provisional is meant to be used from within your application development directory.

~~~ bash
provisional init                    # Create config/provisional/config.yml
provisional image list              # List images (including all versions)
provisional image create image-name # Create an image
provisional image update image-name # Update an image (or all images)
provisional deploy                  # Deploy all images, per config file
~~~


## Why Not Docker?

Docker is overly complex for simple application architectures.
There are a lot of coordination pieces (Fleet, Kubernetes, etc.) required.
We can also store our images with the provider instead of in our own Docker infrastructure.
That said, nothing prevents you from running Docker on top of the VM images you create with Provisional.
You might also be able to adapt Provisional to create Docker images.


## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`,
and then run `bundle exec rake release` to create a git tag for the version,
push git commits and tags, and push the `.gem` file to [RubyGems].


## Contributing

1. Fork the [project repo].
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Make sure tests pass (`rspec` or `rake spec`).
4. Commit your changes (`git commit -am 'Add some feature'`).
5. Push to the branch (`git push origin my-new-feature`).
6. Create a new [pull request].


[project repo]: https://github.com/boochtek/ruby_preserves/fork
[pull request]: https://github.com/boochtek/ruby_preserves/pulls
[RubyGems]: https://rubygems.org
