require 'test/unit'
require 'rbconfig'
require 'rubygems'
require 'rubygems/defaults/operating_system'

class TestDependentSCLS < Test::Unit::TestCase

  def setup
    # Avoid caching
    Gem.class_eval("@default_locations, @default_dirs = nil, nil")
  end

  def test_default_paths
    default_locations = { :system => "/opt/rh/ruby193/root/usr",
                          :local  => "/opt/rh/ruby193/root/usr/local" }
    assert_equal default_locations, Gem.default_locations

    default_dirs = { :system => { :bin_dir => "/opt/rh/ruby193/root/usr/bin",
                                  :gem_dir => "/opt/rh/ruby193/root/usr/share/gems",
                                  :ext_dir => "/opt/rh/ruby193/root/usr/lib64/gems" },
                     :local  => { :bin_dir => "/opt/rh/ruby193/root/usr/local/bin",
                                  :gem_dir => "/opt/rh/ruby193/root/usr/local/share/gems",
                                  :ext_dir => "/opt/rh/ruby193/root/usr/local/lib64/gems" } }
    assert_equal default_dirs, Gem.default_dirs
  end

  # Gem.default_locations and Gem.default_dirs
  # should contain paths to dependent scls binary extensions
  # if the dependent scl adds itself on $GEM_PATH
  #
  # See rhbz#998845
  def test_paths_with_dependent_scl
    prefix = '/some/prefix'
    scl_name = 'ruby_x'

    ENV['X_SCLS'] = "ruby193 #{scl_name}" # enabled scls
    ENV['GEM_PATH'] = "#{prefix}/#{scl_name}/root/usr/share/gems"

    default_locations = { :system => "/opt/rh/ruby193/root/usr",
                          :local  => "/opt/rh/ruby193/root/usr/local",
                          :"#{scl_name}_system" => "#{prefix}/#{scl_name}/root/usr",
                          :"#{scl_name}_local"  => "#{prefix}/#{scl_name}/root/usr/local" }

    assert_equal default_locations, Gem.default_locations

    default_dirs =  { :system => { :bin_dir => "/opt/rh/ruby193/root/usr/bin",
                                   :gem_dir => "/opt/rh/ruby193/root/usr/share/gems",
                                   :ext_dir => "/opt/rh/ruby193/root/usr/lib64/gems" },
                      :local  => { :bin_dir => "/opt/rh/ruby193/root/usr/local/bin",
                                   :gem_dir => "/opt/rh/ruby193/root/usr/local/share/gems",
                                   :ext_dir => "/opt/rh/ruby193/root/usr/local/lib64/gems" },
                      :"#{scl_name}_system" => { :bin_dir => "#{prefix}/#{scl_name}/root/usr/bin",
                                                 :gem_dir => "#{prefix}/#{scl_name}/root/usr/share/gems",
                                                 :ext_dir => "#{prefix}/#{scl_name}/root/usr/lib64/gems" },
                      :"#{scl_name}_local"  => { :bin_dir => "#{prefix}/#{scl_name}/root/usr/local/bin",
                                                 :gem_dir => "#{prefix}/#{scl_name}/root/usr/local/share/gems",
                                                 :ext_dir => "#{prefix}/#{scl_name}/root/usr/local/lib64/gems" } }
    assert_equal default_dirs, Gem.default_dirs
  end

end
