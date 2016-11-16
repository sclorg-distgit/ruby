require 'test/unit'
require 'rbconfig'
require 'rubygems'
require 'rubygems/defaults/operating_system'

class TestDependentSCLS < Test::Unit::TestCase

  def setup
    # TODO: Different bin dir during build ("/builddir/build/BUILD/ruby-2.0.0-p247")
    @bin_dir = Gem::ConfigMap[:bindir].split(File::SEPARATOR).last
    @scl_root = '/opt/rh/@SCL@/root'

    @env_orig = ['X_SCLS', 'GEM_PATH'].inject({}) do |env_orig, key|
      env_orig[key] = ENV[key].dup
      env_orig
    end
  end

  def teardown
    # Avoid caching
    Gem.class_eval("@x_scls, @default_locations, @default_dirs, @get_default_dirs = nil, nil, nil, nil")

    @env_orig.each { |key, val| ENV[key] = val }
  end

  def test_default_paths
    ENV['X_SCLS'] = '@SCL@' # enabled scls

    default_locations = { :system => "#{@scl_root}/usr",
                          :local  => "#{@scl_root}/usr/local" }
    assert_equal default_locations, Gem.default_locations

    default_dirs = { :system => { :bin_dir => "#{@scl_root}/usr/#{@bin_dir}",
                                  :gem_dir => "#{@scl_root}/usr/share/gems",
                                  :ext_dir => "#{@scl_root}/usr/lib64/gems" },
                     :local  => { :bin_dir => "#{@scl_root}/usr/local/#{@bin_dir}",
                                  :gem_dir => "#{@scl_root}/usr/local/share/gems",
                                  :ext_dir => "#{@scl_root}/usr/local/lib64/gems" } }
    assert_equal default_dirs, Gem.default_dirs
  end

  # Gem.default_locations and Gem.default_dirs
  # should contain paths to dependent scls binary extensions
  # if the dependent scl adds itself on $GEM_PATH
  #
  # See rhbz#1034639
  def test_paths_with_dependent_scl
    test_scl = 'ruby_x'
    test_root = "/some/prefix/#{test_scl}/root"

    ENV['X_SCLS'] = "@SCL@ #{test_scl}" # enabled scls
    ENV['GEM_PATH'] = "#{test_root}/usr/share/gems"

    default_locations = { :system => "#{@scl_root}/usr",
                          :local  => "#{@scl_root}/usr/local",
                          :"#{test_scl}_system" => "#{test_root}/usr",
                          :"#{test_scl}_local"  => "#{test_root}/usr/local" }
    assert_equal default_locations, Gem.default_locations

    default_dirs =  { :system => { :bin_dir => "#{@scl_root}/usr/#{@bin_dir}",
                                   :gem_dir => "#{@scl_root}/usr/share/gems",
                                   :ext_dir => "#{@scl_root}/usr/lib64/gems" },
                      :local  => { :bin_dir => "#{@scl_root}/usr/local/#{@bin_dir}",
                                   :gem_dir => "#{@scl_root}/usr/local/share/gems",
                                   :ext_dir => "#{@scl_root}/usr/local/lib64/gems" },
                      :"#{test_scl}_system" => { :bin_dir => "#{test_root}/usr/#{@bin_dir}",
                                                 :gem_dir => "#{test_root}/usr/share/gems",
                                                 :ext_dir => "#{test_root}/usr/lib64/gems" },
                      :"#{test_scl}_local"  => { :bin_dir => "#{test_root}/usr/local/#{@bin_dir}",
                                                 :gem_dir => "#{test_root}/usr/local/share/gems",
                                                 :ext_dir => "#{test_root}/usr/local/lib64/gems" } }
    assert_equal default_dirs, Gem.default_dirs
  end

  def test_empty_x_scls
    ENV['X_SCLS'] = nil # no enabled scls

    default_locations = { :system => "#{@scl_root}/usr",
                          :local  => "#{@scl_root}/usr/local" }
    assert_equal default_locations, Gem.default_locations

    default_dirs = { :system => { :bin_dir => "#{@scl_root}/usr/#{@bin_dir}",
                                  :gem_dir => "#{@scl_root}/usr/share/gems",
                                  :ext_dir => "#{@scl_root}/usr/lib64/gems" },
                     :local  => { :bin_dir => "#{@scl_root}/usr/local/#{@bin_dir}",
                                  :gem_dir => "#{@scl_root}/usr/local/share/gems",
                                  :ext_dir => "#{@scl_root}/usr/local/lib64/gems" } }
    assert_equal default_dirs, Gem.default_dirs
  end

end
