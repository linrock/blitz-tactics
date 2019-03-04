require "rails_helper"

describe "Anoymous users", type: :system do
  before do
    driven_by :selenium, using: :headless_chrome
  end

  it "has no js errors on the homepage " do
    visit "/"
    errors = page.driver.browser.manage.logs.get(:browser)
    expect(errors.length).to eq(0)
    expect(errors.select {|e| e.level == "SEVERE" }.length).to eq(0)
  end

  it "has no js errors on /countdown " do
    visit "/countdown"
    expect(page).to have_text("White to move")
    expect(page).to have_css('.chessboard .piece')
    errors = page.driver.browser.manage.logs.get(:browser)
    expect(errors.select {|e| e.level == "SEVERE" }.length).to eq(0)
  end

  it "has no js errors on /speedrun " do
    visit "/speedrun"
    expect(page).to have_text("White to move")
    expect(page).to have_css('.chessboard .piece')
    errors = page.driver.browser.manage.logs.get(:browser)
    expect(errors.select {|e| e.level == "SEVERE" }.length).to eq(0)
  end

  it "has no js errors on /level-1 " do
    visit "/level-1"
    expect(page).to have_text("White to move")
    expect(page).to have_css('.chessboard .piece')
    errors = page.driver.browser.manage.logs.get(:browser)
    expect(errors.select {|e| e.level == "SEVERE" }.length).to eq(0)
  end

  it "has no js errors on /haste " do
    visit "/haste"
    expect(page).to have_text("Make a move to start the timer")
    expect(page).to have_css('.chessboard .piece')
    errors = page.driver.browser.manage.logs.get(:browser)
    expect(errors.select {|e| e.level == "SEVERE" }.length).to eq(0)
  end

  it "has no js errors on /infinity " do
    visit "/infinity"
    expect(page).to have_text("White to move")
    expect(page).to have_css('.chessboard .piece')
    errors = page.driver.browser.manage.logs.get(:browser)
    expect(errors.select {|e| e.level == "SEVERE" }.length).to eq(0)
  end

  it "redirects to sign up page on /rated " do
    visit "/rated"
    expect(page.current_path).to eq("/users/sign_up")
  end
end
