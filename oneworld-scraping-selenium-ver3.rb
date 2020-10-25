require './url'

require 'selenium-webdriver'

require 'csv'

require 'fileutils'

FileUtils.rm('./list.csv') if File.exist?('list.csv')

driver = Selenium::WebDriver.for :chrome # ブラウザ起動

begin
  $url.each do |url|
    puts "#{url}にアクセスします"
    driver.navigate.to url # URLを開く
    puts '読み込み待ち...'
    sleep 5

    while
      # :timeoutオプションは秒数を指定している。この場合は100秒
      wait = Selenium::WebDriver::Wait.new(timeout: 100)

      puts '読み込み待ち...'

      # untilメソッドは文字通り「～するまで」を意味する
      wait.until { driver.find_element(:class, 'ec-shelfGrid__item').displayed? }

      # 商品ブロックを取得
      selects_listrightbloc = driver.find_elements(:class, 'ec-shelfGrid__item')
      # 商品ブロックの数を取得
      products_size = selects_listrightbloc.length

      products_size.times do |i|
        # :timeoutオプションは秒数を指定している。この場合は100秒
        wait = Selenium::WebDriver::Wait.new(timeout: 100)

        # untilメソッドは文字通り「～するまで」を意味する
        wait.until { driver.find_element(:class, 'ec-shelfGrid__item').displayed? }

        selects_listrightbloc = driver.find_elements(:class, 'ec-shelfGrid__item')
        puts selects_listrightbloc[i].text
        selects_listrightbloc[i].find_element(:tag_name, 'a').click
        # :timeoutオプションは秒数を指定している。この場合は100秒
        wait = Selenium::WebDriver::Wait.new(timeout: 100)

        # untilメソッドは文字通り「～するまで」を意味する
        wait.until { driver.find_element(:class, 'ec-productRole__profile').displayed? }
        product_detail = driver.find_element(:class, 'ec-productRole__profile')
        puts product_detail.text
        # untilメソッドは文字通り「～するまで」を意味する
        wait.until { driver.find_element(:class, 'product-code-default').displayed? }
        
        product_code = product_detail.find_element(:class, 'product-code-default').text

        CSV.open('list.csv', 'a') do |csv|

          item_option = product_detail.find_elements(:id, 'classcategory_id1') # プルダウンのseleniumエレメントを取得

          unless item_option.empty? # 属性ありの処理
            # sleep 2
            item_options = Selenium::WebDriver::Support::Select.new(product_detail.find_element(:tag_name, 'select')) # プルダウンのseleniumエレメントを取得
            item_options.options.each_with_index do |option, i| # item_optionsから選択肢のリストを取り出し、イテレートする
              # puts option.text # プルダウンの中身を表示
              next if option.text == "選択してください"
              item_options.select_by(:index, i) # プルダウンを選択
              sleep 1
              product_code = product_detail.find_element(:class, 'product-code-default').text
              sold_status = product_detail.find_element(:class, 'ec-blockBtn--action').text
               if sold_status.include? "品切"
                stock = 0
               else
                product_stock = product_detail.find_element(:class, 'product-stock').text
                stock = product_stock
               end
              # puts "在庫数：" + product_detail.find_element(:id, 'stock_dynamic').text # 在庫数を取得
              # puts product_detail.find_element(:id, 'product_code_dynamic').text
              csv << [product_code, stock]
            end
          else # 属性なしの時の処理
            # puts "在庫数：" + stock
            # puts product_detail.find_element(:id, 'product_code_default').text
            stock = nil
            wait.until { driver.find_element(:class, 'product-stock').displayed? }
            stock = product_detail.find_element(:class, 'product-stock').text
            break if stock == nil
            csv << [product_code, stock]
          end
        end
        driver.navigate.back

        # sleep 5
      end

      sleep 5

      break if driver.find_elements(:link, '次へ').empty?

      driver.find_element(:link, '次へ').click
    end

    puts '処理は正常に終了ました。(対象URL:#{url})'
  end
  puts "全ての処理が終了しました。"
rescue StandardError => e
  p 'エラーが発生しました'
  p e
  p $ERROR_POSITION
  # エラーを発生させて止める
  raise
end
