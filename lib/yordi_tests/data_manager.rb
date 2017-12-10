require 'yordi_tests'
require 'yordi_tests/local_store'
require 'yordi_tests/image_compare'
require 'yordi_tests/generators/report'
module YordiTests
  module DataManager
    @sub_dir_attr = ''

    module_function

    def sub_dir
      @sub_dir_attr
    end

    def update_sub_dir(v)
      @sub_dir_attr = v
    end

    def default_store(apikey)
      {title: 'YordiTests', apikey: apikey, test_benchmarks: []}
    end

    def create_store
      yordi_path = path_with_sub(YORDI_DIR)
      Dir.mkdir(yordi_path) unless Dir.exist? yordi_path
    end

    def read_store
      config_path = path_with_sub(CONFIG_FILE)
      read_json(config_path)
    end

    def read_report
      config_path = path_with_sub(REPORT_FILE)
      read_json(config_path)
    end

    def read_json(path)
      if File.exist? path
        file = File.read path
        JSON(file)
      else
        puts "No file at: #{path}"
      end

    end

    def save_store(store_hash)
      config_path = path_with_sub(CONFIG_FILE)
      File.open(config_path, 'w') {|file| file.write(store_hash.to_json)}
    end

    # Test entry from the CLI
    def run_test(path_to_screens, name, clean_dir, sync_all, sync_failures, filenames, screens)
      local_store = LocalStore.new(read_store)
      if filenames
        files = []
        filenames.each do |filename|
          files << path_to_screens + '/' + filename
        end
      else
        files = Dir.glob(path_to_screens + '/*.png').sort
      end

      benchmark_root_dir = path_with_sub(BENCHMARKS_PATH)
      screenshot_root_dir = path_with_sub(SCREENS_PATH)
      Dir.mkdir(screenshot_root_dir) unless Dir.exist? screenshot_root_dir
      responses = []
      files.each_with_index do |item, index|
        puts "Testing #{item}"
        screenname = (!screens.nil? && screens.size > index) ? screens[index] : File.basename(item, '.*')
        benchmark = local_store.benchmark_by_screenname(screenname)
        local_name = benchmark.nil? ? screenname + File.extname(item) : benchmark[LOCAL_FILENAME]
        benchmark_path = benchmark_root_dir + "/" + local_name
        screenshot_path = screenshot_root_dir + "/" + local_name
        FileUtils.copy item, screenshot_path
        if benchmark.nil?
          FileUtils.copy item, benchmark_path
          benchmark = {SCREENNAME => screenname,
                       MASKED_AREA => nil,
                       FILENAME => local_name,
                       LOCAL_FILENAME => local_name}
          local_store.update_benchmark(benchmark)
          save_store local_store.data
        end
        global_mask = local_store.get(MASKED_AREA)
        screen_mask = benchmark.nil? ? nil : benchmark[MASKED_AREA]
        response = ImageCompare.perform(screenname, benchmark_path, screenshot_path, global_mask, screen_mask)
        response[LOCAL_FILENAME] = local_name
        responses << response
        File.delete item if clean_dir
      end
      report_path = path_with_sub(REPORT_FILE)
      report_hash = {name: name, tests: responses}
      File.open(report_path, 'w') {|file| file.write(report_hash.to_json)}

      # sync with yorditests.com if desired
      sync_with_yordi local_store, sync_all, sync_failures if sync_all || sync_failures
      generate_report
    end

    def generate_report
      # generate report
      YordiTests::Generators::Report.start([path_with_sub(REPORT_HTML), read_report])

    end

    def sync_with_yordi(store, sync_all, sync_failures)
      # sync with remote
      puts "Syncing with YordiTests"
      report = read_report
      client = YordiTests.get_rest_client
      client.set_apikey store.apikey if store.apikey
      if !report.nil? && report['tests'].size > 0
        reports = report['tests']
        failures = 0
        if sync_failures
          reports.each do |item|
            failures += 1 unless item['passed']
          end
        end
        if sync_all || failures > 0
          client.start report['name']
          screenshot_root_dir = path_with_sub(SCREENS_PATH)
          reports.each do |item|
            puts item[SCREENNAME]
            benchmark = store.benchmark_by_screenname(item[SCREENNAME])
            filename = screenshot_root_dir + '/' + benchmark[LOCAL_FILENAME]
            client.upload filename, item[SCREENNAME] if sync_all || (sync_failures && item['passed'])
          end
          client.stop if sync_all || sync_failures
        end
      end
    end

    # Fetch entry from the CLI
    def fetch(get_benchmarks, get_masks, screens)
      local_store = LocalStore.new(read_store)
      ## no api key
      return unless local_store.apikey

      client = YordiTests.get_rest_client
      client.set_apikey local_store.apikey
      remote_data = client.fetch_application

      ## no remote store
      return unless remote_data

      remote_store = LocalStore.new(remote_data)

      update_store_base(local_store, remote_store)
      replace_benchmarks(client, local_store, remote_store, screens) if get_benchmarks
      replace_masks(local_store, remote_store, screens) if get_masks

      save_store local_store.data
    end


    def path_with_sub(path)
      "#{@sub_dir_attr}#{path}"
    end


    def update_store_base(local_store, remote_store)
      local_store.put(TITLE, remote_store.get(TITLE))
      local_store.put(APIKEY, remote_store.apikey)
    end

    def replace_benchmarks(client, local_store, remote_store, screens)
      # no api key
      screens = remote_store.all_screens unless screens
      benchmark_root_dir = path_with_sub(BENCHMARKS_PATH)

      Dir.mkdir(benchmark_root_dir) unless Dir.exist? benchmark_root_dir

      screens.each do |screen|
        benchmark = remote_store.benchmark_by_screenname(screen)
        next unless benchmark

        benchmark[LOCAL_FILENAME] = sanitize(screen) + File.extname(benchmark[FILENAME])

        # download benchmark
        puts "Downloading #{screen}"
        benchmark_image = client.fetch_benchmark(screen)

        # update store to reflex file name of benchmark
        file_path = "#{benchmark_root_dir}/#{benchmark[LOCAL_FILENAME]}"
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


    def sanitize(filename)
      # Remove any character that aren't 0-9, A-Z, or a-z
      filename.gsub(/[^0-9A-Z]/i, '_')
    end
  end
end
