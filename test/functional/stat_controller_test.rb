require 'test_helper'

class StatControllerTest < ActionController::TestCase
  test "should get panel" do
    get :panel
    assert_response :success
  end

  test "should get results" do
    get :results
    assert_response :success
  end

  test "should get details" do
    get :details
    assert_response :success
  end

end
