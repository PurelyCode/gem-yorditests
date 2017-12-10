require 'test_helper'
require 'fileutils'
require 'yordi_tests'
require 'yordi_tests/cli'
require 'yordi_tests/local_store'
require_relative 'mock_client'
class TestCli < Minitest::Test

  def setup
    YordiTests.set_rest_client YordiTests::Impl.create(MockClient)
    YordiTests::DataManager.update_sub_dir 'tmp/'
    args = %w[init -k api]
    YordiTests::CLI.start(args)
  end

  def teardown
    if Dir.exist?("tmp/#{YordiTests::YORDI_DIR}")
      FileUtils.remove_dir("tmp/#{YordiTests::YORDI_DIR}")
    end
  end

  ## test the fetch command
  def test_fetch_benchmarks
    args = %w[fetch -b]
    YordiTests::CLI.start(args)
  end

  def test_fetch_masks
    args = %w[fetch -m]
    YordiTests::CLI.start(args)

  end

  def test_fetch_all
    args = %w[fetch -b -m]
    YordiTests::CLI.start(args)
  end

  def test_fetch_none
    args = %w[fetch]
    YordiTests::CLI.start(args)
  end

  def test_fetch_all_for_screens
    args = %w[fetch -b -m -s 01-altijdmindful-login 09-altijdmindful-detail-pauzed]
    YordiTests::CLI.start(args)
  end

end
