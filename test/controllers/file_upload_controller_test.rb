require 'test_helper'

class FileUploadControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get file_upload_index_url
    assert_response :success
  end

end
