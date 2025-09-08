require "test_helper"

class Admin::WorkoutsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_workouts_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_workouts_show_url
    assert_response :success
  end

  test "should get new" do
    get admin_workouts_new_url
    assert_response :success
  end

  test "should get create" do
    get admin_workouts_create_url
    assert_response :success
  end

  test "should get edit" do
    get admin_workouts_edit_url
    assert_response :success
  end

  test "should get update" do
    get admin_workouts_update_url
    assert_response :success
  end

  test "should get destroy" do
    get admin_workouts_destroy_url
    assert_response :success
  end
end
