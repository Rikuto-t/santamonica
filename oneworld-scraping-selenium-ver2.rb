require './difinition'

require 'selenium-webdriver'

require 'csv'

require "fileutils"

FileUtils.rm("./list.csv")

driver = Selenium::WebDriver.for :chrome # ブラウザ起動

driver.navigate.to $url[0] # URLを開く
sleep 10

while driver.find_elements(:link, '次へ>>').length > 0
  # 商品ブロックを取得
  selects_listrightbloc = driver.find_elements(:class, 'listrightbloc')
  #商品ブロックの数を取得
  products_size = selects_listrightbloc.length

  products_size.times do |i|
    selects_listrightbloc = driver.find_elements(:class, 'listrightbloc')
    selects_listrightbloc[i].find_element(:tag_name, 'h3').click
    sleep 5
    detailrightbloc = driver.find_element(:id, 'detailrightbloc')
    stock_default = detailrightbloc.find_element(:id, 'stock_default').text
    CSV.open("list.csv", "a") do |csv|
      if stock_default.include?("～") # 属性ありの処理
         item_options = Selenium::WebDriver::Support::Select.new(detailrightbloc.find_element(:tag_name, 'select')) # プルダウンのseleniumエレメントを取得
         item_options.options.each_with_index do |option, i| #item_optionsから選択肢のリストを取り出し、イテレートする
           puts option.text # プルダウンの中身を表示
           item_options.select_by(:index, i) # プルダウンを選択
           puts "在庫数：" + detailrightbloc.find_element(:id, 'stock_dynamic').text # 在庫数を取得
           puts detailrightbloc.find_element(:id, 'product_code_dynamic').text
           csv << [detailrightbloc.find_element(:id, 'product_code_dynamic').text, stock_default]
         end
      else # 属性なしの時の処理
        puts "在庫数：" + stock_default
        puts detailrightbloc.find_element(:id, 'product_code_default').text
        csv << [detailrightbloc.find_element(:id, 'product_code_default').text, detailrightbloc.find_element(:id, 'stock_dynamic').text]
      end
    end
    driver.navigate.back
    sleep 5
  end

  driver.find_element(:link, '次へ>>').click
end



# selects_listrightbloc = driver.find_elements(:class, 'listrightbloc')
#
# selects_listrightbloc.each_with_index do |item, i|
#
#   puts "商品名：" + item.find_element(:tag_name, 'h3').text
#   stock = item.find_element(:id, 'stock_default').text
#
#   if stock.include?("～") # 属性ありの処理
#      item_options = Selenium::WebDriver::Support::Select.new(item.find_element(:tag_name, 'select')) # プルダウンのseleniumエレメントを取得
#      # TODO:プルダウンの一つ目の「選択してください」を消す処理を入れるのをやめ、CSV出力時に削除することにする
#
#      item_options.options.each_with_index do |option, i| #item_optionsから選択肢のリストを取り出し、イテレートする
#        puts option.text # プルダウンの中身を表示
#        item_options.select_by(:index, i) # プルダウンを選択
#        puts "在庫数：" + item.find_element(:id, 'stock_dynamic').text # 在庫数を取得
#      end
#   else # 属性なしの時の処理
#     puts "在庫数：" + stock
#   end
#
# end


driver.quit # ブラウザ終了
