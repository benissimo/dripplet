require 'test_helper'

class WaterPointsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:water_points)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create water_point" do
    assert_difference('WaterPoint.count') do
      post :create, :water_point => { }
    end

    assert_redirected_to water_point_path(assigns(:water_point))
  end

  test "should show water_point" do
    get :show, :id => water_points(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => water_points(:one).to_param
    assert_response :success
  end

  test "should update water_point" do
    put :update, :id => water_points(:one).to_param, :water_point => { }
    assert_redirected_to water_point_path(assigns(:water_point))
  end

  test "should destroy water_point" do
    assert_difference('WaterPoint.count', -1) do
      delete :destroy, :id => water_points(:one).to_param
    end

    assert_redirected_to water_points_path
  end
end
