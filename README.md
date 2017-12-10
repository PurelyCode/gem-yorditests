# YordiTests CLI 

The yordi_tests gem is a companion for [YordiTests](https://yorditests.com). 
This project is rapidly changing and in alpha phase, use at your own risk. 

Basically YordiTests compares screenshots with benchmarks and can apply masks to hide dynamic content. 

It only works with PNG files and requires the files to have the extensions .png for now and does not recurse directories. 

## Installation

<!-- Add this line to your application's Gemfile:

```ruby
gem 'yordi_tests'
```

And then execute:

    $ bundle
Or -->
Install it yourself as:

    $ gem install yordi_tests

## Usage
It's a CLI with Thor so calling help on the command line will give you more details
``` ruby
  yordi help
```
To start a .yordi_tests directory must be initialized, either of these commands will create the directory relative 
to the where you execute it. Using an apikey will automatically sync your local test directory with the benchmarks online. 
``` ruby
  yordi help init  # for all the options
  yordi init   
  yordi init --api_key apikey_from_yorditests.com
```
To test your screenshots
``` ruby
  yordi help test  # for more options
  yordi test /path/to/screenshots
  yordi test /path/to/screenshots --sync-all # push the new screenshots to yorditests.com
  yordi test /path/to/screenshots --clean-dir # after the tests it deletes the screenshots tested
```
Show the report (only works on OSX, the report is located at .yordi_tests/report.html)
``` ruby 
  yordi open_report  # opens the last generated html report
```
Refetch benchmarks and masks from online
``` ruby 
  yordi help fetch  # for more options
  yordi fetch -bm  # fetches all benchmark details and masks from online for testing
```
Push benchmarks and masks to online store (not yet implemented)
``` ruby 
  yordi help push  # for more options
  yordi push -bm  # pushes all benchmark details and masks to online store
```
### Standalone Scenario
So you have run an appium or selenium test that made a lot of screenshots.
Wherever you want to run your yordi test do the following.
``` ruby
  yordi init
  yordi test path/to/screenshot
  yordi open_report
```
At which point you will see a report and all of your screens will have passed the test as there was no benchmark.
So run your appium or selenium tests again and create the screenshots a second time.
``` ruby
  yordi test path/to/screenshot
  yordi open_report
```
Now there is a good chance that some of your screenshots haved failed the test due to status bars with time or other
dynamic issues. If the screen changes are different but valid you need to mask this dynamic area to ensure 100% on the test. 
This is easiest done with YordiTests.com editor, however the masks are simple JSON areas. 

So if you don't want to use YordiTests.com you can manually open the config.json at .yordi_tests/config.json
and add some rectangles for masks as a value for masked_area: in the json, 
you can use any image editing program to get the x, y, width and height you want 

Here is an example of a masked_area value, masked_area is an array. 
``` javascript
  masked_area: [
     {
           "x": 0,
           "y": 0,
           "width": 800,
           "height": 48
     },
    {
           "x": 419,
           "y": 385,
           "width": 619,
           "height": 372
     },
     
     
   ]
```
In the config.json the property masked_area: is available in the root and in individual screens in the test_benchmarks array. 
Placing a mask in root will have the mask be applied to all screens during the comparision. Placing the mask on a screen will apply the mask only to that screen.
So the screens get compared after both the benchmark and resulting screenshot have all global and local masks applied. 

At some point you will want to update your benchmarks, for example if the design has changed. If you are using YordiTests.com 
then if you sync your tests with the online store you can make the screenshot the benchmark online
and then re-fetch the benchmarks from the comand with `yordi fetch -b`.  

However if you are running in standalone mode to update a benchmark at the moment you must manually copy the 
screenshot into the benchmark folder in the subdirectories of .yordi_tests.  Eventually a command will be added to make this easier. 


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/PurelyCode/gem-yorditests.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
