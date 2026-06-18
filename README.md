# Rebundler

Rebundler automatically reorders and annotates your Gemfile.

## Why would you want that?

- **No more manual ordering of gems.** Let's admit that you usually just put them somewhere vaguely adjacent. Eventually your Gemfile will be a mess.
- **No bike shedding about the structure of your Gemfile.** Rebundler will take care of it.
- **More context on what gems do.** Especially with all the funky gem names in our community (which is fun!) it's not entirely clear from most names alone what it does. Rebundler will add a comment with the gem's description.

## Example

Take this small Gemfile:

```ruby
source "https://rubygems.org"

gem "rails"
gem "puma"
gem "avo"

group :development do
  gem "herb"
end
```

After running Rebundler, the gems are sorted, and each one is annotated with its description:

```ruby
source "https://rubygems.org"

gem "avo" # Admin panel framework and Content Management System for Ruby on Rails.
gem "puma" # A Ruby/Rack web server built for parallelism.
gem "rails" # Full-stack web application framework.

group :development do
  gem "herb" # The modern HTML+ERB Toolchain
end
```

## Try it online

You can play around with Rebundler in the [Rebundler Playground](https://rebundler.dev/). Just paste your Gemfile and hit **Rebundle**. It encodes the Gemfile in a hash in the URL, so you can easily share the result with others.

## Known limitations

- **Probably does not work with all possible Gemfile configurations.** It is designed to work with the most common setups right now. If you encounter an issue, please open an issue on GitHub. I strive to support most sensible configurations.
- **Non-trailing comments are discarded.** Rebundler keeps existing trailing comments on `gem` lines, but standalone comments and commented-out gems are removed.

## Installation

Add it to your Gemfile with `bundle add rebundler`, or install it standalone with `gem install rebundler`. There are two ways to run Rebundler.

### 1. Writing mode

If you run `bundle exec rebundle`, rebundler will reorder and annotate your Gemfile.

```sh
$ bundle exec rebundle
Reordering and annotating Gemfile...
✓ Gemfile has been reordered and annotated
```

### 2. CI mode

If you run `bundle exec rebundle --ci`, rebundler will run in CI mode, which will compare the output
of the current Gemfile to a freshly formatted one.

If there are differences, rebundler will exit with a non-zero status code.

This does not write to the Gemfile.

```sh
❯ bundle exec rebundle --ci
Checking if Gemfile is properly formatted...
✓ Gemfile is properly formatted
```

### Options

### `--force`

By default, Rebundler preserves existing trailing comments on `gem` defining lines. If you want to overwrite them anyway, use the `--force` flag:

```sh
$ bundle exec rebundle --force
```

## Interface

You can also use Rebundler directly in Ruby rather than via the CLI.

### `Parser.from_file(path)`

Parses a Gemfile at the given path and returns a `Parser` instance.

```ruby
parser = Rebundler::Parser.from_file("/path/to/Gemfile")
```

### `Parser.from_string(content)`

Parses a Gemfile from a string and returns a `Parser` instance.

```ruby
content = File.read("/path/to/Gemfile")
parser = Rebundler::Parser.from_string(content)
```

### `parser.format(overwrite_comments: false)`

Returns the formatted Gemfile content as a string. Does not write to disk.

Pass `overwrite_comments: true` to replace existing trailing comments on `gem` lines (equivalent to the `--force` CLI flag):

```ruby
new_content = parser.format(overwrite_comments: true)
```

## How it works

Since Gemfiles are just regular Ruby files, Rebundler parses them with [Prism](https://github.com/ruby/prism). It walks the AST using Prism's visitor pattern to find `gem` declarations and groups, while keeping generic setup methods like `source`, `ruby`, and `git_source` at the top.

Gems defined at the top level are grouped together. Gems inside blocks (like `group :development do ... end`) stay within their block, and duplicate groups are automatically merged. Within each group, gems are sorted alphabetically.

Prism is only a parser, not a formatter, so Rebundler reconstructs the Gemfile with some string manipulation. Because Prism records the exact line and column of every node, Rebundler copies the original source for each gem verbatim — which keeps your existing style intact. It then loads each gem's description from your local bundle (fetching it from RubyGems if it's missing) and appends it as a trailing comment.

By default, existing trailing comments are kept and other comments are discarded.

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle exec minitest` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dennispaagman/rebundler.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
