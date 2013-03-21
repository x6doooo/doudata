#encoding: utf-8
require 'RubyGems'
require 'mysql'
require 'json'

sql = Mysql.new('localhost', 'root', '', 'test')
data = sql.query('SELECT tags,participant_count,photo_count,liked_count,recs_count FROM actives_data').to_a

tags = []
length = 0;
data.each do |val|
  #需要删除中文标点符号并将这些符号都替换成|线
  val[0] = val[0].gsub(/[\s,.!@#$\%^&]/,'').split('|')
  val[0].each do |v|
    tem = []
    if tags.include?(v)
      record = sql.query("SELECT tag,participant_count,photo_count,liked_count,recs_count FROM actives_tags WHERE tag = '#{v}'").to_a[0]
      4.times do |i|
        tem[i+1] = record[i+1].to_i + val[i+1].to_i
      end
      odr = "UPDATE actives_tags SET participant_count=#{tem[1]},photo_count=#{tem[2]},liked_count=#{tem[3]},recs_count=#{tem[4]} WHERE tag = '#{v}'"
      puts odr
      sql.query(odr)
    else
      tags.push(v)
      odr = "INSERT into actives_tags (tag,participant_count,photo_count,liked_count,recs_count) VALUES ('#{v}','#{val[1]}','#{val[2]}','#{val[3]}','#{val[4]}')"
      puts odr
      sql.query(odr)
    end
  end
  puts length
  length += 1
end

