# Rebundler

Rebundler automatically reorders and annotates your Gemfile.

## Why would you want that?

- **No more manual ordering of gems.** Let's admit that you usually just put them somewhere vaguely adjacent. Eventually your Gemfile will be a mess.
- **No bike shedding about the structure of your Gemfile.** Rebundler will take care of it.
- **More context on what gems do.** Especially with all the funky gem names in our community (which is fun!) it's not entirely clear from most names alone what it does. Rebundler will add a comment with the gem's description.

## Example

This is a real life example from my own project. That looks a lot better, doesn't it?

| Before                                                                                    | After                                                                                     |
| ----------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| ![image](https://github.com/user-attachments/assets/42a76744-111b-4f73-bc62-8723637e6655) | ![image](https://github.com/user-attachments/assets/3ea6c70e-2239-4511-9040-c4db58203ec4) |

## Known limitations

- **Probably does not work with all possible Gemfile configurations.** It is designed to work with the most common setups right now. If you encounter an issue, please open an issue on GitHub. I strive to support most sensible configurations.

## Installation

First add `rebundler` to your Gemfile. `bundle add rebundler`. There are two ways to run Rebundler.

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

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle exec minitest` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dennispaagman/rebundler.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
