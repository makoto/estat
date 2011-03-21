# -*- coding: UTF-8 -*-
require 'rubygems'
require 'capybara'
require 'capybara/rspec'
require 'capybara/mechanize'
require 'selenium-webdriver'
require 'rack'

Capybara.app = Rack::Builder.new
Capybara.app_host = "http://www.e-stat.go.jp/"
Capybara.default_wait_time = 30
Capybara.register_driver :selenium do |app|
    # Capybara::Driver::Selenium.new(app, :browser => :chrome)
    Capybara::Driver::Selenium.new(app, :browser => :firefox, :profile => "e-stat")
end
Capybara.default_driver = :selenium

# Not working as expected
# Create your own profile using /Applications/Firefox.app/Contents/MacOS/firefox-bin -profilemanager
# Then 
# Selenium::WebDriver.for :firefox, :profile => "e-stat"

Spec::Runner.configure do |config| 
  config.include(Capybara, :type => :request) 
end

describe "the signup process", :type => :request do
  it "signs me in" do
    visit '/SG1/estat/toukeiChiri.do?method=init'
    page.driver.browser.execute_script %Q{
      document.links[7].removeAttribute('target');
    }
    click_link("データダウンロード")
    select('平成１７年国勢調査（小地域）　2005/10/01')
    check('d1_tT000051')
    click_button("　次　へ　")
    select('岩手県')
    all('select[name="selectedCities"] option')[0..2].each do |node|
      p node.text
      select(node.text)
      #  Gets  Element not found in the cache error
      # node.select_option unless node.selected?
    end
    click_button(" 検　索 ")
    p "getting table"
    all('table tbody')[4..4].each do |table|
      table.all('a').each do |a|
        unless a.text == "定義書"
          p a.text
          a.click
          
          # sleep 20
          # Not working. Maybe beacuse this is browser dialog, rather than javascript popup.
          # page.driver.browser.within_popup do
          #   p "within popup"
          #   # choose("Save File")
          #   click_button("OK")
          # end
        end
      end
    end
  end
end