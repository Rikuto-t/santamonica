require './difinition'

require 'selenium-webdriver'

require 'csv'

require 'fileutils'

FileUtils.rm('./list.csv') if File.exist?('list.csv')

driver = Selenium::WebDriver.for :chrome # ブラウザ起動

# 要素がロードされるまでの待ち時間を60秒に設定
# driver.manage.timeouts.implicit_wait = 60

$url.each do |url|
  puts "#{url}にアクセスします"
  driver.navigate.to url # URLを開く
  puts "読み込み待ち..."
   sleep 5
  begin
    while
      # :timeoutオプションは秒数を指定している。この場合は100秒
      wait = Selenium::WebDriver::Wait.new(timeout: 100)

      puts "読み込み待ち..."

      # untilメソッドは文字通り「～するまで」を意味する
      wait.until { driver.find_element(:class, 'listrightbloc').displayed? }

      # 商品ブロックを取得
      selects_listrightbloc = driver.find_elements(:class, 'listrightbloc')
      # 商品ブロックの数を取得
      products_size = selects_listrightbloc.length

      products_size.times do |i|
        # :timeoutオプションは秒数を指定している。この場合は100秒
        wait = Selenium::WebDriver::Wait.new(timeout: 100)

        # untilメソッドは文字通り「～するまで」を意味する
        wait.until { driver.find_element(:class, 'listrightbloc').displayed? }

        selects_listrightbloc = driver.find_elements(:class, 'listrightbloc')
        puts selects_listrightbloc[i].text
        selects_listrightbloc[i].find_element(:tag_name, 'h3').click
        # sleep 5
        detailrightbloc = driver.find_element(:id, 'detailrightbloc')
        stock_default = detailrightbloc.find_element(:id, 'stock_default').text
        CSV.open('list.csv', 'a') do |csv|
          if stock_default.include?('～') # 属性ありの処理
            # sleep 2
            item_options = Selenium::WebDriver::Support::Select.new(detailrightbloc.find_element(:tag_name, 'select')) # プルダウンのseleniumエレメントを取得
            item_options.options.each_with_index do |_option, i| # item_optionsから選択肢のリストを取り出し、イテレートする
              # puts option.text # プルダウンの中身を表示
              item_options.select_by(:index, i) # プルダウンを選択
              # puts "在庫数：" + detailrightbloc.find_element(:id, 'stock_dynamic').text # 在庫数を取得
              # puts detailrightbloc.find_element(:id, 'product_code_dynamic').text
              csv << [detailrightbloc.find_element(:id, 'product_code_dynamic').text, detailrightbloc.find_element(:id, 'stock_dynamic').text]
            end
          else # 属性なしの時の処理
            # puts "在庫数：" + stock_default
            # puts detailrightbloc.find_element(:id, 'product_code_default').text
            csv << [detailrightbloc.find_element(:id, 'product_code_default').text, stock_default]
          end
        end
        driver.navigate.back

        # sleep 5
      end

      sleep 5

      break if driver.find_elements(:link, '次へ>>').empty?

      driver.find_element(:link, '次へ>>').click
    end


    puts '処理は正常に終了ました。(対象URL:url)'
  rescue StandardError => e
    p driver.current_url
    p 'エラーが発生しました'
    p e
    p $ERROR_POSITION
  end
end
