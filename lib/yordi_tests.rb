require 'yordi_tests/version'
require 'yordi_tests/client'
module YordiTests

  HOST = ENV['YORDI_HOST'].freeze || 'https://yorditests.com'.freeze
  START_PATH = '/api/v1/start'.freeze
  UPLOAD_PATH = '/api/v1/upload'.freeze
  STOP_PATH = '/api/v1/stop'.freeze
  FETCH_APPLICATION = '/api/v1/fetch_application'.freeze
  PUSH_BENCHMARK = '/api/v1/push_benchmarks'.freeze
  PUSH_MASK = '/api/v1/push_masks'.freeze
  FETCH_BENCHMARK = '/api/v1/benchmark'.freeze


  YORDI_DIR = ENV['YORDI_DIR'].freeze || '.yordi_tests'.freeze
  BENCHMARKS_PATH = YORDI_DIR + '/benchmarks'.freeze
  SCREENS_PATH = YORDI_DIR + '/screenshots'.freeze
  CONFIG_FILE = YORDI_DIR + '/config.json'.freeze
  REPORT_FILE = YORDI_DIR + '/report.json'.freeze
  REPORT_HTML = YORDI_DIR + '/report.html'.freeze

  module_function

  def client=(v)
    @client = v
  end

  def client
    @client
  end

  # set default value
  @client = Client

  def new_client(apikey)
    client = new
    client.extend(Client)
    client.apikey = apikey
    client
  end
end
