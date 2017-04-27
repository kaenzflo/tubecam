require 'test_helper'

class TubecamstationsControllerTest < ActionDispatch::IntegrationTest

=begin
  setup do
    @tubecamstation = tubecamstations(:one)
  end

  test "should get index" do
    get tubecamstations_url
    assert_response :success
  end

  test "should get new" do
    get new_tubecamstation_url
    assert_response :success
  end

  test "should create tubecamstation" do
    assert_difference('Tubecamstation.count') do
      post tubecamstations_url, params: { tubecamstation: { active: @tubecamstation.active, description: @tubecamstation.description, serialnumber: @tubecamstation.serialnumber, status: @tubecamstation.status, user_id: @tubecamstation.user_id } }
    end

    assert_redirected_to tubecamstation_url(Tubecamstation.last)
  end

  test "should show tubecamstation" do
    get tubecamstation_url(@tubecamstation)
    assert_response :success
  end

  test "should get edit" do
    get edit_tubecamstation_url(@tubecamstation)
    assert_response :success
  end

  test "should update tubecamstation" do
    patch tubecamstation_url(@tubecamstation), params: { tubecamstation: { active: @tubecamstation.active, description: @tubecamstation.description, serialnumber: @tubecamstation.serialnumber, status: @tubecamstation.status, user_id: @tubecamstation.user_id } }
    assert_redirected_to tubecamstation_url(@tubecamstation)
  end

  test "should destroy tubecamstation" do
    assert_difference('Tubecamstation.count', -1) do
      delete tubecamstation_url(@tubecamstation)
    end

    assert_redirected_to tubecamstations_url
  end

=end
end
