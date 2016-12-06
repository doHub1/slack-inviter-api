require 'test_helper'

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @error = errors(:one)
  end

  test "should get index" do
    get errors_url, as: :json
    assert_response :success
  end

  test "should create error" do
    assert_difference('Error.count') do
      post errors_url, params: { error: { not_found: @error.not_found } }, as: :json
    end

    assert_response 201
  end

  test "should show error" do
    get error_url(@error), as: :json
    assert_response :success
  end

  test "should update error" do
    patch error_url(@error), params: { error: { not_found: @error.not_found } }, as: :json
    assert_response 200
  end

  test "should destroy error" do
    assert_difference('Error.count', -1) do
      delete error_url(@error), as: :json
    end

    assert_response 204
  end
end
