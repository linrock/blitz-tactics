require "rails_helper"

describe "Anoymous users", type: :system do
  before do
    driven_by :selenium, using: :headless_chrome
  end

  def expect_no_js_errors(page)
    errors = page.driver.browser.manage.logs.get(:browser)
    errors = errors.select {|e| %w( SEVERE WARNING ).include? e.level }
    errors.each do |e|
      expect(e.level).not_to eq(e.level), e.message
    end
  end

  it "has no js errors on the homepage " do
    visit "/"
    expect_no_js_errors(page)
  end

  it "has no js errors on /countdown " do
    visit "/countdown"
    expect(page.text).to match(/(White|Black) to move/)
    expect_no_js_errors(page)
    expect(page).to have_css('.chessboard .piece')
  end

  it "has no js errors on /speedrun " do
    visit "/speedrun"
    expect(page.text).to match(/(White|Black) to move/)
    expect_no_js_errors(page)
    expect(page).to have_css('.chessboard .piece')
  end

  it "has no js errors on /level-1 " do
    visit "/level-1"
    expect(page).to have_text("White to move")
    expect_no_js_errors(page)
    expect(page).to have_css('.chessboard .piece')
  end

  it "has no js errors on /haste " do
    visit "/haste"
    expect(page).to have_text("Make a move to start the timer")
    expect_no_js_errors(page)
    expect(page).to have_css('.chessboard .piece')
  end

  it "has no js errors on /infinity " do
    visit "/infinity"
    expect(page.text).to match(/(White|Black) to move/)
    expect_no_js_errors(page)
    expect(page).to have_css('.chessboard .piece')
  end

  it "redirects to sign up page on /rated " do
    visit "/rated"
    expect(page.current_path).to eq("/users/sign_up")
  end
end
