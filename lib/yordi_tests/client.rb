require 'rest-client'
require 'yordi_tests'
module YordiTests

  module Client
    def get_apikey
      @api_key
    end

    def set_apikey(v)
      @api_key = v
    end

    def auth_header
      "Bearer #{@api_key}"
    end

    # @param [String] test_name
    def start(test_name)
      response = RestClient::Request.execute(method: :get, url: HOST + START_PATH,
                                             payload: {name: test_name}, headers: {authorization: auth_header})
      @test_key = JSON(response)['testkey']
      true
    end

    # @param [String] screenshot_path
    # @param [String] screen_name
    def upload(screenshot_path, screen_name)
      RestClient.post(HOST + UPLOAD_PATH,
                      {screenshot: File.new(screenshot_path),
                       screenname: screen_name, testkey: @test_key},
                      authorization: auth_header)
      true
    end

    def stop
      RestClient::Request.execute(method: :get, url: HOST + STOP_PATH,
                                  payload: {testkey: @test_key}, headers: {authorization: auth_header})

      true
    end

    def fetch_application
      response = RestClient::Request.execute(method: :get, url: HOST + FETCH_APPLICATION,
                                             payload: {}, headers: {authorization: auth_header})
      JSON(response)
    end

    def fetch_benchmark(screen_name)
      RestClient::Request.execute(method: :get, url: HOST + FETCH_BENCHMARK,
                                  payload: {screenname: screen_name}, headers: {authorization: auth_header})

    end


  end
end