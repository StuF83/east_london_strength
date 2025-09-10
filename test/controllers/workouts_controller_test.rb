require "test_helper"

class WorkoutsControllerTest < ActionDispatch::IntegrationTest
  test "should get today" do
    get workouts_today_url
    assert_response :success
  end

  test "should get show" do
    get workouts_show_url
    assert_response :success
  end
end
