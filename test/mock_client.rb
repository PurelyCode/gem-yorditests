require 'json'
module MockClient
  @@api_key

  def get_apikey
    @@api_key
  end

  def set_apikey(v)
    @@api_key = v
  end


  # @param [String] test_name
  def start(test_name)
    @@test_key = 'mocked_key'
    true
  end

  # @param [String] screenshot_path
  # @param [String] screen_name
  def upload(screenshot_path, screen_name)
    true
  end

  def stop
    true
  end

  def fetch_application
    app_file = 'test/fixtures/application.json'
    if File.exist? app_file

      file = File.read app_file
      JSON(file)
    else
      throw Exception("No config file at: #{app_file}")
    end

  end

  def fetch_benchmark(screenname)
    benchmark_file = "test/fixtures/benchmarks/#{screenname}.png"
    File.read benchmark_file if File.exist? benchmark_file
  end
end