class PagesController < ApplicationController
  # The welcome page is a complete HTML document, so it skips the application layout.
  def home
    render layout: false
  end
end
