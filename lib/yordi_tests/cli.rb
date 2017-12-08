require 'thor'
require 'rest-client'
require 'json'
module YordiTests
  class CLI < Thor
    package_name 'YordiTests'

    desc 'init --api_key', 'Initializes a Yordi test directory at .yordi_tests, use an apikey to sync with online service'
    method_option :api_key, type: :string, aliases: "-k", desc: "this is how it works"
    def init()
      if options.api_key
        puts "init #{options.api_key}"
      else

        puts "init"
      end
    end


    desc 'test PATH_TO_SCREENSHOTS', 'Run a yordi test on all images in folder'
    method_option :name, type: :string, default: 'Generic Test', aliases: '-n', desc: 'Name for this test in history online.'
    method_option :clean_dir, type: :boolean, default: false, aliases: '-D', desc: 'Delete all screenshots in the folder you specified after test completes.'
    method_option :sync_all, type: :boolean, default: false, aliases: '-s', desc: 'Push all screens to YordiTests.com for evaluation.'
    method_option :sync_failures, type: :boolean, default: false, aliases: '-f', desc: 'Push only failed screens to YordiTests.com for evaluation.'
    def test(path_to_screens)
      puts "test #{path_to_screens}"
    end

    desc 'fetch', 'Fetch remote data from YordiTests.com'
    method_option :benchmarks, type: :boolean, default: false, aliases: '-b', desc: 'Fetch benchmarks'
    method_option :masks, type: :boolean, default: false, aliases: '-m', desc: 'Fetch masks'
    method_option :screens, type: :array, aliases: '-s', desc: 'Only fetch items associated with this list of screen names'
    def fetch()
      puts "test #{}"
    end

    desc 'push', 'Push local data to YordiTests.com'
    method_option :benchmarks, type: :boolean, default: false, aliases: '-b', desc: 'Push benchmarks'
    method_option :masks, type: :boolean, default: false, aliases: '-m', desc: 'Push masks'
    method_option :screens, type: :array, aliases: '-s', desc: 'Only push items associated with this list of screen names'
    def push(path_to_screens)
      puts "test #{path_to_screens}"
    end


    desc 'open_report', 'Open the last generated report'
    def open_report()
      puts "test #{}"
    end


  end
end
