require 'test_helper'

class TubecamDevicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tubecam_device = tubecam_devices(:one)
  end

  test "should get index" do
    get tubecam_devices_url
    assert_response :success
  end

  test "should get new" do
    get new_tubecam_device_url
    assert_response :success
  end

  test "should create tubecam_device" do
    assert_difference('TubecamDevice.count') do
      post tubecam_devices_url, params: { tubecam_device: { active: @tubecam_device.active, description: @tubecam_device.description, serialnumber: @tubecam_device.serialnumber, user_id: @tubecam_device.user_id } }
    end

    assert_redirected_to tubecam_device_url(TubecamDevice.last)
  end

  test "should show tubecam_device" do
    get tubecam_device_url(@tubecam_device)
    assert_response :success
  end

  test "should get edit" do
    get edit_tubecam_device_url(@tubecam_device)
    assert_response :success
  end

  test "should update tubecam_device" do
    patch tubecam_device_url(@tubecam_device), params: { tubecam_device: { active: @tubecam_device.active, description: @tubecam_device.description, serialnumber: @tubecam_device.serialnumber, user_id: @tubecam_device.user_id } }
    assert_redirected_to tubecam_device_url(@tubecam_device)
  end

  test "should destroy tubecam_device" do
    assert_difference('TubecamDevice.count', -1) do
      delete tubecam_device_url(@tubecam_device)
    end

    assert_redirected_to tubecam_devices_url
  end
end
