require 'yordi_tests'
require 'yordi_tests/data_store'
require 'yordi_tests/image_compare'
require 'yordi_tests/generators/report'
module YordiTests
  module DataManager
    module_function

    def default_store(apikey)
      {title: 'YordiTests', apikey: apikey, test_benchmarks: []}
    end


    # Create Store
    #
    #   Called during init process on the CLI
    #
    def create_store(apikey)
      verify_directories
      store = DataManager.default_store(apikey)
      puts "Saving store #{CONFIG_FILE}"
      DataManager.save_store store
    end

    # Fetch
    #
    #  used in the fetch command from the CLI
    #
    def fetch(get_benchmarks, get_masks, screens)
      verify_directories
      local_store = DataStore.new(read_store)
      ## no api key
      return unless local_store.apikey

      client = YordiTests.client
      client.apikey = local_store.apikey
      remote_data = client.fetch_application

      ## no remote store
      return unless remote_data

      remote_store = DataStore.new(remote_data)

      local_store.update_root_data(remote_store.title, remote_store.apikey)
      replace_benchmarks(client, local_store, remote_store, screens) if get_benchmarks
      replace_masks(local_store, remote_store, screens) if get_masks

      save_store local_store.data
    end

    # Generate a report
    #
    #  Used in the make_report command from the CLI
    #
    def generate_report
      YordiTests::Generators::Report.start([REPORT_HTML, read_report])
    end

    # RunTest
    #
    #  USed in the test command from the CLI
    def run_test(path_to_screens, name, clean_dir, sync_all, sync_failures, filenames, screens)
      verify_directories
      store = DataStore.new(read_store)
      if filenames
        files = []
        filenames.each do |filename|
          files << File.join(path_to_screens, filename)
        end
      else
        files = Dir.glob(File.join(path_to_screens, '*.png')).sort
      end
      responses = []
      files.each_with_index do |item, index|
        puts "Testing #{item}"
        screenname = !screens.nil? && screens.size > index ? screens[index] : File.basename(item, '.*')
        benchmark = store.benchmark_by_screenname(screenname)
        local_name = benchmark.nil? ? sanitize(screenname) + File.extname(item) : benchmark[LOCAL_FILENAME]
        benchmark_path = File.join(BENCHMARKS_PATH, local_name)
        screenshot_path = File.join(SCREENS_PATH, local_name)
        FileUtils.copy item, screenshot_path
        if benchmark.nil?
          FileUtils.copy item, benchmark_path
          benchmark = store.add_benchmark(screenname, local_name)
          save_store store.data
        end
        global_mask = store.get(MASKED_AREA)
        screen_mask = benchmark.nil? ? nil : benchmark[MASKED_AREA]
        response = ImageCompare.perform(benchmark_path, screenshot_path, global_mask, screen_mask)
        response[SCREENNAME] = screenname
        response[LOCAL_FILENAME] = local_name
        responses << response
        File.delete item if clean_dir
      end
      report_hash = {name: name, tests: responses}
      save_report(report_hash)

      # sync with yorditests.com if desired
      sync_with_yordi store, sync_all, sync_failures if sync_all || sync_failures
      generate_report
    end

    # helper functions

    def store?
      Dir.exist? YORDI_DIR
    end

    def read_store
      read_json(CONFIG_FILE)
    end

    def read_report
      read_json(REPORT_FILE)
    end

    def read_json(path)
      if File.exist? path
        file = File.read path
        JSON(file)
      else
        puts "No file at: #{path} did you call initialize this directory"
      end

    end
    def save_report(store_hash)
      save_data(REPORT_FILE, store_hash)
    end

    def save_store(store_hash)
      save_data(CONFIG_FILE, store_hash)
    end
    def save_data(file_path, hash)
      File.open(file_path, 'w') {|file| file.write(hash.to_json)}
    end



    def sync_with_yordi(store, sync_all, sync_failures)
      # sync with remote
      return unless store.apikey
      puts 'Syncing with YordiTests'
      report = read_report
      client = YordiTests.client
      client.apikey = store.apikey
      if !report.nil? && !report['tests'].empty?
        reports = report['tests']
        failures = 0
        if sync_failures
          reports.each do |item|
            failures += 1 unless item['passed']
          end
        end

        if sync_all || failures > 0
          client.start report['name']
          reports.each do |item|
            next unless sync_all || !item['passed']
            puts item[SCREENNAME]
            benchmark = store.benchmark_by_screenname(item[SCREENNAME])
            filename = File.join(SCREENS_PATH, benchmark[LOCAL_FILENAME])
            client.upload filename, item[SCREENNAME]
          end
          client.stop
        end
      end
    end

    def replace_benchmarks(client, local_store, remote_store, screens)

      # no api key
      screens = remote_store.all_screens unless screens

      screens.each do |screen|
        benchmark = remote_store.benchmark_by_screenname(screen)
        next unless benchmark

        benchmark[LOCAL_FILENAME] = sanitize(screen) + File.extname(benchmark[FILENAME])

        # download benchmark
        puts "Downloading #{screen}"
        benchmark_image = client.fetch_benchmark(screen)

        # update store to reflex file name of benchmark
        file_path = File.join(BENCHMARKS_PATH, benchmark[LOCAL_FILENAME])
        File.open(file_path, 'w') {|file| file.write(benchmark_image)}
        local_store.update_benchmark(benchmark)
      end
    end

    def replace_masks(local_store, remote_store, screens)
      # global mask
      local_store.put(MASKED_AREA, remote_store.get(MASKED_AREA))
      screens = remote_store.all_screens unless screens
      screens.each do |screen|
        benchmark = remote_store.benchmark_by_screenname(screen)
        # download benchmark
        puts "Update mask for #{screen}"
        local_store.update_mask(benchmark) if benchmark
      end
    end

    def verify_directories
      Dir.mkdir(YORDI_DIR) unless Dir.exist? YORDI_DIR
      Dir.mkdir(BENCHMARKS_PATH) unless Dir.exist? BENCHMARKS_PATH
      Dir.mkdir(SCREENS_PATH) unless Dir.exist? SCREENS_PATH
    end

    def sanitize(filename)
      # Remove any character that aren't 0-9, A-Z, or a-z
      filename.gsub(/[^0-9A-Z]/i, '_')
    end
  end
end
