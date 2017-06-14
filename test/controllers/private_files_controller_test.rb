require 'test_helper'

class PrivateFilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @private_file = private_files(:one)
  end

  test "should get index" do
    get private_files_url, as: :json
    assert_response :success
  end

  test "should create private_file" do
    assert_difference('PrivateFile.count') do
      post private_files_url, params: { private_file: {  } }, as: :json
    end

    assert_response 201
  end

  test "should show private_file" do
    get private_file_url(@private_file), as: :json
    assert_response :success
  end

  test "should update private_file" do
    patch private_file_url(@private_file), params: { private_file: {  } }, as: :json
    assert_response 200
  end

  test "should destroy private_file" do
    assert_difference('PrivateFile.count', -1) do
      delete private_file_url(@private_file), as: :json
    end

    assert_response 204
  end
end
