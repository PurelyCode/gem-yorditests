require 'json'
require 'rest-client'

module YordiTests
  class Client
    HOST = 'https://yorditests.com'.freeze
    START_PATH = '/api/v1/start'.freeze
    UPLOAD_PATH = '/api/v1/upload'.freeze
    STOP_PATH = '/api/v1/stop'.freeze

    # @param [String] api_key
    def initialize(api_key)
      @api_key = api_key
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
  end
end