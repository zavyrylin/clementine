require "test/unit"

class ClojureScriptEngineTest < Test::Unit::TestCase

  def self.jruby?
    defined?(RUBY_ENGINE) && RUBY_ENGINE == "jruby"
  end

  def jruby?
    self.class.jruby?
  end

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    require "#{File.join(File.dirname(__FILE__), "..", "lib", "clementine")}"
    require "#{File.join(File.dirname(__FILE__), "..", "lib", "clementine", "clojurescript_engine")}"
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_default_option
    engine = Clementine::ClojureScriptEngine.new("", "")
    assert_not_nil engine.default_opts
  end

  def test_convert_options
    options = {:optimizations => :advanced,  :output_dir => "#{Dir.pwd}", :pretty_print => true}
    engine = Clementine::ClojureScriptEngine.new("", "")
    opts = engine.convert_options(options)

    if jruby?
      assert_equal 3, opts.length
      opts.keys.each {|k| assert_equal Java::clojure.lang.Keyword, k.class }
      assert_equal [":optimizations", ":output-dir", ":pretty-print"], opts.keys.map(&:to_s).sort

      opts.each do |k, v|
        case k.to_s
        when ":optimizations" then assert_equal ":advanced", v.to_s
        when ":output-dir"    then assert_equal "#{Dir.pwd}", v.to_s
        when ":pretty-print"  then assert_equal "true", v.to_s
        end
      end
    else
      assert_match %r{{:optimizations :advanced :output-dir \".*\" :pretty-print true}}, opts
    end
  end

  if jruby?
    def test_created_clojure_map
      options = {:optimizations => :advanced,  :output_dir => "#{Dir.pwd}", :pretty_print => true}
      engine = Clementine::ClojureScriptEngine.new("", "")
      opts = engine.convert_options(options)
      map = PersistentHashMap.create(opts)
      assert_equal 3, map.length
      map.each do |k, v|
        assert_equal Java::clojure.lang.Keyword, k.class
        assert [":optimizations", ":output-dir", ":pretty-print"].include? k.to_s
      end
    end
  end
end
