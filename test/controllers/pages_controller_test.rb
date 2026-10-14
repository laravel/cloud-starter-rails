require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "the welcome page responds" do
    get root_path

    assert_response :success
    assert_select "h1", "Your Rails app is up and running on Laravel Cloud."
    assert_includes response.body, "Your Rails app is up and running on Laravel Cloud."
    assert_includes response.body, "Rails #{Rails.version} · Ruby #{RUBY_VERSION}"
  end
end
