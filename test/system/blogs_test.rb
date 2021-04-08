require "application_system_test_case"

class BlogsTest < ApplicationSystemTestCase
  setup do
    @blog = blogs(:one)
  end

  test "visiting the index" do
    visit blogs_url
    assert_selector "h1", text: "Blogs"
  end

  test "creating a Blog" do
    visit blogs_url
    click_on "New Blog"

    fill_in "Body html", with: @blog.body_html
    fill_in "Body markdown", with: @blog.body_markdown
    fill_in "Canonical url", with: @blog.canonical_url
    fill_in "Cover image", with: @blog.cover_image
    fill_in "Description", with: @blog.description
    fill_in "Hosted on", with: @blog.hosted_on
    fill_in "Readable publish date", with: @blog.readable_publish_date
    fill_in "Slug", with: @blog.slug
    fill_in "Social image", with: @blog.social_image
    fill_in "Title", with: @blog.title
    fill_in "Url", with: @blog.url
    click_on "Create Blog"

    assert_text "Blog was successfully created"
    click_on "Back"
  end

  test "updating a Blog" do
    visit blogs_url
    click_on "Edit", match: :first

    fill_in "Body html", with: @blog.body_html
    fill_in "Body markdown", with: @blog.body_markdown
    fill_in "Canonical url", with: @blog.canonical_url
    fill_in "Cover image", with: @blog.cover_image
    fill_in "Description", with: @blog.description
    fill_in "Hosted on", with: @blog.hosted_on
    fill_in "Readable publish date", with: @blog.readable_publish_date
    fill_in "Slug", with: @blog.slug
    fill_in "Social image", with: @blog.social_image
    fill_in "Title", with: @blog.title
    fill_in "Url", with: @blog.url
    click_on "Update Blog"

    assert_text "Blog was successfully updated"
    click_on "Back"
  end

  test "destroying a Blog" do
    visit blogs_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Blog was successfully destroyed"
  end
end
