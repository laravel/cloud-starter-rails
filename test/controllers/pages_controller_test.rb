require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "the home page responds" do
    get root_path

    assert_response :success
    assert_select "h1", "Hello from Laravel Cloud"
  end
end
