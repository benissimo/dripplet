require 'profile_test_helper'
require 'performance_test_help'

# Profiling results for each test method are written to tmp/performance.
class ProfileBrowsingTest < ActionController::PerformanceTest
  def test_profile_homepage
    get '/'
  end
end
