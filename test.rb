# -*- coding: UTF-8 -*-
require 'rubygems'
require 'capybara'
require 'capybara/rspec'
require 'capybara/mechanize'
require 'selenium-webdriver'
require 'rack'

Capybara.app = Rack::Builder.new
Capybara.app_host = "http://www.e-stat.go.jp/"
Capybara.default_wait_time = 400
Capybara.register_driver :selenium do |app|
  # Capybara::Driver::Selenium.new(app, :browser => :chrome)
  # NOTE: Create your own "e-stat" using /Applications/Firefox.app/Contents/MacOS/firefox-bin -profilemanager
  # Then go through e-stat page using the profile, save some files, and click "Do this automatically for files like this from now on".
  # This is to avoid popup to come up when saving files. You may not need to do this if you choose chrome, but I haven't tried that route yet.
  Capybara::Driver::Selenium.new(app, :browser => :firefox, :profile => "e-stat")
end
Capybara.default_driver = :selenium

Spec::Runner.configure do |config| 
  config.include(Capybara, :type => :request) 
end

describe "the signup process", :type => :request do
  Prefs = ["北海道", "青森県", "岩手県", "宮城県", "秋田県", "山形県", "福島県", "茨城県", "栃木県", "群馬県", "埼玉県", "千葉県", "東京都", "神奈川県", "新潟県", "富山県", "石川県", "福井県", "山梨県", "長野県", "岐阜県", "静岡県", "愛知県", "三重県", "滋賀県", "京都府", "大阪府", "兵庫県", "奈良県", "和歌山県", "鳥取県", "島根県", "岡山県", "広島県", "山口県", "徳島県", "香川県", "愛媛県", "高知県", "福岡県", "佐賀県", "長崎県", "熊本県", "大分県", "宮崎県", "鹿児島県", "沖縄県"]
  
  Prefs.each do |pref|
    it "#{pref} should be downloaded" do
    data = []
    
    p "Start time: #{Time.now}"
    visit '/SG1/estat/toukeiChiri.do?method=init'
    page.driver.browser.execute_script %Q{
      document.links[7].removeAttribute('target');
    }
    click_link("データダウンロード")
    select('平成１７年国勢調査（小地域）　2005/10/01')
    check('d1_tT000051')
    click_button("　次　へ　")
    puts "Prefecture : #{pref} : #{Time.now}"
    select(pref)
    all('select[name="selectedCities"] option').each do |node|
      p "Choosing city : #{node.text} : #{Time.now}"
      select(node.text)
      #  Gets  Element not found in the cache error
      # node.select_option unless node.selected?
    end
    click_button(" 検　索 ")
    p "getting table"
    all('table tbody')[4..4].each do |table|
      table.all('a').each do |a|
        unless a.text == "定義書"
          p "City : #{a.text} : #{Time.now}"
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
    p data
  p "End time: #{Time.now}"
  end
  end

end