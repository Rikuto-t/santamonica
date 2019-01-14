### nokogiriをつかったスクレイピング実験ファイルです
### プルダウンに対応できていません

# URLにアクセスするためのライブラリの読み込み
require 'open-uri'
# Nokogiriライブラリの読み込み
require 'nokogiri'
# CSV出力を可能にする
require 'csv'

# スクレイピング先のURL
url = 'http://1world.co.jp/online/products/list.php?transactionid=152559f594748e9dfb1f3d050a81b4e6ec0ff205&mode=&category_id=89&maker_id=0&name=&orderby=&disp_number=30&pageno=2&rnd=cra'

charset = nil
html = open(url) do |f|
  charset = f.charset # 文字種別を取得
  f.read # htmlを読み込んで変数htmlに渡す
end

# htmlをパース(解析)してオブジェクトを生成
doc = Nokogiri::HTML.parse(html, nil, charset)

CSV.open("list.csv", "w") do |csv|
  doc.xpath('//div[@class="listrightbloc"]').each_with_index do |node,i|
    name = node.xpath("//h3")[i + 1]
    stock = node.xpath("//span[@id='stock_default']")[i + 1]
    csv << [name, stock]
  end
end
