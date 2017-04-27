require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

=begin
  setup do
    @janysev1 = users(:janysev1)
  end



  test "login with information" do
    get new_user_session_path
    assert_select "h2", "Anmelden"
    assert_select "input[value=?]", "Anmelden"
    post user_session_url, params: { user: { email: "janysev1@students.zhaw.ch", password: "janysev1" } }
    #follow_redirect!
    assert_equal 200, status
    assert_template "/media", path
  end
=end

end
