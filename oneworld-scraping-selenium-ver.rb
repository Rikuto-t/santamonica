
require 'selenium-webdriver'

require 'csv'


driver = Selenium::WebDriver.for :chrome # ブラウザ起動


driver.navigate.to 'http://1world.co.jp/online/products/list.php?transactionid=152559f594748e9dfb1f3d050a81b4e6ec0ff205&mode=&category_id=89&maker_id=0&name=&orderby=&disp_number=30&pageno=2&rnd=cra' # URLを開く


selects_listrightbloc = driver.find_elements(:class, 'listrightbloc')

selects_listrightbloc.each_with_index do |item, i|

  puts "商品名：" + item.find_element(:tag_name, 'h3').text
  stock = item.find_element(:id, 'stock_default').text

  if stock.include?("～") # 属性ありの処理
     item_options = Selenium::WebDriver::Support::Select.new(item.find_element(:tag_name, 'select')) # プルダウンのseleniumエレメントを取得
     # TODO:プルダウンの一つ目の「選択してください」を消す処理を入れるのをやめ、CSV出力時に削除することにする

     item_options.options.each_with_index do |option, i| #item_optionsから選択肢のリストを取り出し、イテレートする
       puts option.text # プルダウンの中身を表示
       item_options.select_by(:index, i) # プルダウンを選択
       puts "在庫数：" + item.find_element(:id, 'stock_dynamic').text # 在庫数を取得
     end
  else # 属性なしの時の処理
    puts "在庫数：" + stock
  end

end


driver.quit # ブラウザ終了
