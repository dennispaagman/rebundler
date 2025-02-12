# Rebundler

Rebundler automatically reorders and annotes your Gemfile.


## Why would you want that?

* **No more manual ordering of gems.** Let's admit that you usually just put them somewhere  vaguely adjacent. Eventually your Gemfile will be a mess.
* **No bike shedding about the structure of your Gemfile.** Rebundler will take care of it.
* **More context on what gems do.** Especially with all the funky gem names in our community (which is fun!) it's not entirely clear from most names alone what it does. Rebundler will add a comment with the gem's description.

## Example

This is a real life example from my own project. That looks a lot better, doesn't it?

| Before | After |
| ------ | ----- |
| ![image](https://github.com/user-attachments/assets/42a76744-111b-4f73-bc62-8723637e6655) | ![image](https://github.com/user-attachments/assets/3ea6c70e-2239-4511-9040-c4db58203ec4) |


## Known limitations

* **Existing comments will be lost.** At this moment Rebundler does not persist existing comments.
* **Probably does not work with all possible Gemfile configurations.** It is designed to work with the most common setups right now. If you encounter an issue, please open an issue on GitHub. I strive to support each sensible configuration.

## Installation

There are two ways to install Rebundler.

### 1. Automatic mode

Simply add them gem to your Gemfile. the location does not matter as it will be resorted immediately.

```ruby
gem "rebundler"
```

This installs a Bundler plugin that automatically runs after installing gems. You should see a message in your terminal after running `bundle`:

```sh
$ bundle

...

Reordering and annotating Gemfile...
Bundle complete! 10 Gemfile dependencies, 45 gems now installed.
```

### 2. Manual mode

```ruby
gem "rebundler", require: false
```

This does **not** load the plugin and means you have to run rebundler yourself by running a Rake task:

```sh
$ rake rebundle
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dennispaagman/rebundler.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
