require 'test_helper'

class ErrorControllerTest < ActionDispatch::IntegrationTest
  test "should get error" do
    get error_error_url
    assert_response :success
  end

end
