require 'yordi_tests'
require 'mini_magick'
require 'securerandom'
require 'yordi_tests/local_store'
module YordiTests
  module ImageCompare
    module_function

    def addMask(image_path, global_mask, screen_mask)
      output_path = "#{image_path}#{SecureRandom.hex}.png"
      convert = MiniMagick::Tool::Convert.new(whiny: false)
      convert << image_path
      convert.fill('white')
      convert.stroke('none')
      unless screen_mask.nil?
        screen_mask.each do |item|
          convert.draw("rectangle #{item['x']}, #{item['y']} #{item['x'] + item['width']},#{item['y'] + item['height']}")
        end
      end
      unless global_mask.nil?
        global_mask.each do |item|
          convert.draw("rectangle #{item['x']}, #{item['y']} #{item['x'] + item['width']},#{item['y'] + item['height']}")
        end
      end
      convert << output_path

      convert.call do |stdout, stderr, status|
        unless stderr.nil?
          # error_count = stderr.to_i
        end
      end
      output_path
    end

    def perform(screenname, benchmark_path, screenshot_path, global_mask, screen_mask)
      response = {screenname: screenname, passed: false, message: 'None', has_diff: false, diff: nil}

      #compare images
      # begin
      screenshot = MiniMagick::Image.open(screenshot_path)
      benchmark_screenshot = MiniMagick::Image.open(benchmark_path)
      if screenshot.nil?
        response[:message] = 'Screen shot unreadable'
      elsif benchmark_screenshot.nil?
        response[:message] = 'Benchmark image unreadable'
      elsif screenshot.width != benchmark_screenshot.width || screenshot.height != benchmark_screenshot.height
        response[:message] = 'Screenshot has wrong dimensions'

      else
        if screenshot.signature == benchmark_screenshot.signature
          response[:passed] = true
          response[:message] = 'Screenshot is perfect'
        else
          compare_mask_one = addMask(benchmark_path, global_mask, screen_mask)
          compare_mask_two = addMask(screenshot_path, global_mask, screen_mask)

          image_diff = "#{screenshot_path}.diff.png"
          compare = MiniMagick::Tool::Compare.new(whiny: false)
          compare.metric('AE')
          compare.fuzz('5%')

          compare << compare_mask_one
          compare << compare_mask_two
          #  compare.compose('Src')
          compare << image_diff

          error_count = 0
          compare.call do |stdout, stderr, status|
            unless stderr.nil?
              error_count = stderr.to_i
            end
          end

          if error_count.zero?
            response[:passed] = true
            response[:message] = 'Screenshot seems to be the same.'
          else
            response[:message] = 'Hmm, has something changed, WTF!'
          end

          response[:diff] = image_diff
          response[:has_diff] = true
          File.delete(compare_mask_one) unless compare_mask_one.nil?
          File.delete(compare_mask_two) unless compare_mask_two.nil?

        end
      end
      response

    end
  end
end