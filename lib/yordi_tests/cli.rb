require 'thor'
require 'yordi_tests'
require 'yordi_tests/data_manager'
module YordiTests
  class CLI < Thor
    package_name 'YordiTests'

    desc 'init --api_key', 'Initializes a Yordi test directory at .yordi_tests relative to where you execute the command'
    method_option :api_key, type: :string, aliases: '-k', desc: 'APIKEY from YordiTest.com if you want to sync results online'
    method_option :force, type: :boolean, aliases: '-f', desc: 'Force re-initialization'
    method_option :verbose, type: :boolean, default: false, aliases: '-v', desc: 'Suppress console output'

    def init
      YordiTests.verbose = options.verbose
      YordiTests.safe_puts 'init'
      if DataManager.store?
        YordiTests.safe_puts 'Already initialized'
        exit(1) unless options.force
      end
      YordiTests.safe_puts "Initializing #{YORDI_DIR} "
      DataManager.create_store(options.api_key)

      return unless options.api_key
      YordiTests.safe_puts 'Fetching remote store.'
      DataManager.fetch(true, true, nil)
    end


    desc 'test PATH_TO_SCREENSHOTS', 'Run a Yordi test on all images in folder'
    method_option :name, type: :string, default: 'Generic Test', aliases: '-n', desc: 'Name for this test in report.'
    method_option :clean_dir, type: :boolean, default: false, aliases: '-D', desc: 'This will DELETE all screenshots in PATH_TO_SCREENSHOTS after test completes.'
    method_option :sync_all, type: :boolean, default: false, aliases: '-a', desc: 'Push all screens to YordiTests.com for evaluation.'
    method_option :sync_failures, type: :boolean, default: false, aliases: '-f', desc: 'Push only failed screens to YordiTests.com for evaluation.'
    method_option :filenames, type: :array, aliases: '-i', desc: 'Only test these specific files'
    method_option :screens, type: :array, aliases: '-s', desc: 'Give the files a name other than there filename in the report (best used with -i option)'
    method_option :verbose, type: :boolean, default: false, aliases: '-v', desc: 'Suppress console output'

    def test(path_to_screens)
      YordiTests.verbose = options.verbose
      YordiTests.safe_puts "Testing #{path_to_screens} name: #{options.name}, clean_dir: #{options.clean_dir}, sync_all: #{options.sync_all}, sync_failures: #{options.sync_failures}, filenames: #{options.filenames}, screens: #{options.screens}"
      DataManager.run_test(path_to_screens, options.name, options.clean_dir, options.sync_all, options.sync_failures, options.filenames, options.screens)
    end

    desc 'make_report', 'Regenerate a Yordi report based on json report'

    method_option :verbose, type: :boolean, default: false, aliases: '-v', desc: 'Suppress console output'
    def make_report
      YordiTests.verbose = options.verbose
      DataManager.generate_report
    end

    desc 'fetch', 'Fetch remote data from YordiTests.com'
    method_option :benchmarks, type: :boolean, default: false, aliases: '-b', desc: 'Fetch benchmarks'
    method_option :masks, type: :boolean, default: false, aliases: '-m', desc: 'Fetch masks'
    method_option :screens, type: :array, aliases: '-s', desc: 'Only fetch items associated with this list of screen names'
    method_option :verbose, type: :boolean, default: false, aliases: '-v', desc: 'Suppress console output'

    def fetch
      YordiTests.verbose = options.verbose
      YordiTests.safe_puts "Fetching with options benchmarks: #{options.benchmarks}, masks: #{options.masks}, screens: #{options.screens}"
      DataManager.fetch(options.benchmarks, options.masks, options.screens)
    end

    desc 'push', 'Push local data to YordiTests.com'
    method_option :benchmarks, type: :boolean, default: false, aliases: '-b', desc: 'Push benchmarks'
    method_option :masks, type: :boolean, default: false, aliases: '-m', desc: 'Push masks'
    method_option :screens, type: :array, aliases: '-s', desc: 'Only push items associated with this list of screen names'
    method_option :verbose, type: :boolean, default: false, aliases: '-v', desc: 'Suppress console output'

    def push(path_to_screens)
      YordiTests.verbose = options.verbose
      YordiTests.safe_puts "test #{path_to_screens}"
    end


    desc 'open_report', 'Open the last generated report'

    def open_report
      system "open #{REPORT_HTML}"
    end


  end
end
