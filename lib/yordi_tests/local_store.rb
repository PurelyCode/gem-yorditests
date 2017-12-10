require 'yordi_tests'
module YordiTests
  BENCHMARKS = 'test_benchmarks'.freeze
  SCREENNAME = 'screenname'.freeze
  FILENAME = 'filename'.freeze
  MASKED_AREA = 'masked_area'.freeze
  APIKEY = 'apikey'.freeze
  LOCAL_FILENAME = 'local_filename'.freeze
  TITLE = 'title'.freeze

  class LocalStore

    def initialize(json_store)
      @store = json_store
    end

    def apikey
      get(APIKEY)
    end

    def data
      @store
    end

    def put(key, data)
      @store[key] = data
    end

    def get(key)
      return @store[key].dup unless @store[key].nil?
      nil
    end

    def all_screens
      screens = []
      @store[BENCHMARKS].each do |benchmark|
        screens << benchmark[SCREENNAME]
      end
      screens
    end

    def update_benchmark(benchmark)
      benchmark_pos = benchmark_pos_by_screenname(benchmark[SCREENNAME])
      if benchmark_pos < 0
        @store[BENCHMARKS] << benchmark.dup
      else
        @store[BENCHMARKS][benchmark_pos][SCREENNAME] = benchmark[SCREENNAME]
        @store[BENCHMARKS][benchmark_pos][FILENAME] = benchmark[FILENAME]
        @store[BENCHMARKS][benchmark_pos][LOCAL_FILENAME] = benchmark[LOCAL_FILENAME]
      end
    end

    def update_mask(benchmark)
      benchmark_pos = benchmark_pos_by_screenname(benchmark[SCREENNAME])
      if benchmark_pos < 0
        @store[BENCHMARKS] << benchmark.dup
      else
        @store[BENCHMARKS][benchmark_pos][MASKED_AREA] = benchmark[MASKED_AREA].dup unless benchmark[MASKED_AREA].nil?
      end
    end

    def benchmark_by_screenname(screenname)
      @store[BENCHMARKS].each do |benchmark|
        return benchmark.dup if screenname.eql? benchmark[SCREENNAME]
      end
      nil
    end

    def benchmark_pos_by_screenname(screenname)
      @store[BENCHMARKS].each_with_index do |benchmark, index|
        return index if screenname.eql? benchmark[SCREENNAME]
      end
      -1
    end
  end
end