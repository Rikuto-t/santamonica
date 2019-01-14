
require 'selenium-webdriver'

require 'csv'


driver = Selenium::WebDriver.for :chrome # ブラウザ起動

driver.navigate.to 'http://1world.co.jp/online/products/list.php?transactionid=152559f594748e9dfb1f3d050a81b4e6ec0ff205&mode=&category_id=89&maker_id=0&name=&orderby=&disp_number=30&pageno=2&rnd=cra' # URLを開く


#　在庫取得　試しに１つめのリーシュから

element = element.find_element(:tag_name, 'select')      # 要素名で指定
a = select.select_by(:index, 1)             # インデックス（0始まり）で選択
puts a





driver.quit # ブラウザ終了
