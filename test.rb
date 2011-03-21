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
  
  # TooBig = ["北海道", "福島県", "茨城県", "埼玉県", "千葉県", "東京都", "神奈川県"]
  # Done = ["青森県", "岩手県", "宮城県", "秋田県", "山形県"]
  # Done = ["宮城県", "秋田県", "山形県", "栃木県","群馬県"]
  # Prefs = ["北海道", "青森県", "岩手県", "宮城県", "秋田県", "山形県", "福島県", "茨城県", "栃木県", "群馬県", "埼玉県", "千葉県", "東京都", "神奈川県", "新潟県", "富山県", "石川県", "福井県", "山梨県", "長野県", "岐阜県", "静岡県", "愛知県", "三重県", "滋賀県", "京都府", "大阪府", "兵庫県", "奈良県", "和歌山県", "鳥取県", "島根県", "岡山県", "広島県", "山口県", "徳島県", "香川県", "愛媛県", "高知県", "福岡県", "佐賀県", "長崎県", "熊本県", "大分県", "宮崎県", "鹿児島県", "沖縄県"]
  # Prefs = ["北海道","福島県","茨城県", "埼玉県", "千葉県", "東京都", "神奈川県", "新潟県", "富山県", "石川県", "福井県", "山梨県", "長野県", "岐阜県", "静岡県", "愛知県", "三重県", "滋賀県", "京都府", "大阪府", "兵庫県", "奈良県", "和歌山県", "鳥取県", "島根県", "岡山県", "広島県", "山口県", "徳島県", "香川県", "愛媛県", "高知県", "福岡県", "佐賀県", "長崎県", "熊本県", "大分県", "宮崎県", "鹿児島県", "沖縄県"]
  Prefs = ["福島県","茨城県", "埼玉県", "千葉県", "神奈川県","新潟県", "富山県", "群馬県", "山梨県", "長野県", "静岡県", "栃木県", "東京都"] 
  
  Prefs.each do |pref|
    it "#{pref} should be downloaded" do
      data = []
      stat_time = Time.now
      p "Start time: #{stat_time}"
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

      cities = []
      previous_cities = []
      current_cities = []
      all('select[name="selectedCities"] option').each do |node|
        cities << node.text
      end
      
      cities.each_slice(5) do |part_of_cities|
        current_cities = part_of_cities
        
        previous_cities.each do |city|
          unselect(city)
        end
        
        part_of_cities.each do |city|
          p "Selecting city : #{city} : #{Time.now}"
          select(city)
        end
        previous_cities = current_cities
        click_button(" 検　索 ")
        get_table
      end
      p data
      end_time = Time.now
      p "Start time: #{stat_time} , End time: #{end_time}, Took #{end_time - stat_time} sec"
    end
  end
  
  def get_table
    p "getting table"
    all('table tbody')[4..4].each do |table|
      table.all('a').each do |a|
        unless a.text == "定義書"
          p "City : #{a.text} : #{Time.now}"
          a.click
        end
      end
    end
  end
end