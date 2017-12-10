require 'yordi_tests/version'
require 'yordi_tests/client'
module YordiTests
  DEFAULT_APIKEY = "none"

  #HOST = 'https://yorditests.com'.freeze
  HOST = 'http://localhost:3000'.freeze
  START_PATH = '/api/v1/start'.freeze
  UPLOAD_PATH = '/api/v1/upload'.freeze
  STOP_PATH = '/api/v1/stop'.freeze
  FETCH_APPLICATION = '/api/v1/fetch_application'.freeze
  PUSH_BENCHMARK = '/api/v1/push_benchmarks'.freeze
  PUSH_MASK = '/api/v1/push_masks'.freeze
  FETCH_BENCHMARK = '/api/v1/benchmark'.freeze


  YORDI_DIR = '.yordi_tests'.freeze
  BENCHMARKS_PATH = YORDI_DIR + '/benchmarks'.freeze
  SCREENS_PATH = YORDI_DIR + '/screenshots'.freeze
  CONFIG_FILE = YORDI_DIR + '/config.json'.freeze
  REPORT_FILE = YORDI_DIR + '/report.json'.freeze
  REPORT_HTML = YORDI_DIR + '/report.html'.freeze


  # this function is to allow injection of the
  # rest client for mocking in tests
  class Impl
    def self.create provider
      o = new
      o.extend(provider)
    end
  end

  module_function

  def get_rest_client
    @rest_client
  end

  def set_rest_client(v)
    @rest_client = v
  end

  # set default value
  @rest_client = YordiTests::Impl.create(Client)

end
