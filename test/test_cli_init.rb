require 'test_helper'
require 'fileutils'
require 'yordi_tests'
require 'yordi_tests/cli'
require 'yordi_tests/data_store'
require_relative 'mock_client'
class TestCliInit < Minitest::Test

  def setup
    YordiTests.client = MockClient
  end

  def teardown
    if Dir.exist?(YordiTests::YORDI_DIR)
      FileUtils.remove_dir(YordiTests::YORDI_DIR)
    end
  end

  ## test the init commend
  def test_init_with_apikey
    args = %w[init -k apikey]
    YordiTests::CLI.start(args)
    verify_content_generation_init
  end

  def test_init_without_apikey
    args = %w[init]
    YordiTests::CLI.start(args)
    verify_content_generation_init
  end


  private

  def verify_content_generation_init
    assert Dir.exist?(YordiTests::YORDI_DIR), 'Dir has not been created'
    assert File.exist?(YordiTests::CONFIG_FILE), 'Config file has not been created'
  end

end
