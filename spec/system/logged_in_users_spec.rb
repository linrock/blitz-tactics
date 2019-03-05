require "rails_helper"

describe "Logged-in users", type: :system do
  before do
    driven_by :selenium, using: :headless_chrome
  end

  let(:username) { "myusername" }
  let(:password) { "password" }
  let!(:user)    { User.create!(username: username, password: password) }

  def expect_no_js_errors(page)
    errors = page.driver.browser.manage.logs.get(:browser)
    errors = errors.select {|e| %w( SEVERE WARNING ).include? e.level }
    errors.each do |e|
      expect(e.level).not_to eq(e.level), e.message
    end
  end

  def sign_in
    visit "/users/sign_in"
    fill_in "user_username", with: username
    fill_in "user_password", with: password
    click_on "Log in"
  end

  it "signs in from /users/sign_in" do
    sign_in
    expect(page.current_path).to eq("/")
    expect(page).to have_text(username.upcase)
  end

  it "has no js errors on the homepage " do
    sign_in
    visit "/"
    expect_no_js_errors(page)
  end

  it "has no js errors on /countdown " do
    sign_in
    visit "/countdown"
    expect(page.text).to match(/(White|Black) to move/)
    expect_no_js_errors(page)
    expect(page).to have_css('.chessboard .piece')
  end

  it "has no js errors on /speedrun " do
    sign_in
    visit "/speedrun"
    expect(page.text).to match(/(White|Black) to move/)
    expect_no_js_errors(page)
    expect(page).to have_css('.chessboard .piece')
  end

  it "has no js errors on /level-1 " do
    sign_in
    visit "/level-1"
    expect(page).to have_text("White to move")
    expect_no_js_errors(page)
    expect(page).to have_css('.chessboard .piece')
  end

  it "has no js errors on /haste " do
    sign_in
    visit "/haste"
    expect(page).to have_text("Make a move to start the timer")
    expect_no_js_errors(page)
    expect(page).to have_css('.chessboard .piece')
  end

  it "has no js errors on /infinity " do
    sign_in
    visit "/infinity"
    expect(page.text).to match(/(White|Black) to move/)
    expect_no_js_errors(page)
    expect(page).to have_css('.chessboard .piece')
  end

  it "has no js errors on /rated " do
    sign_in
    visit "/rated"
    expect(page.text).to match(/(White|Black) to move/)
    expect_no_js_errors(page)
    expect(page.current_path).to eq("/rated")
    expect(page).to have_css('.chessboard .piece')
  end
end
