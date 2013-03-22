#encoding: utf-8
require 'RubyGems'
require 'net/https'
require 'mysql'
require 'json'
require '../modules/api_getter'


#获取豆瓣线上活动数据

$has_it = []

#获取数据
class Worker < API_getter
  attr_accessor :json, :sql
  #从接口获取一组数据
  def get_active_info(start, count)
    @json = @https.get(@uri.path + "?cate=latest&start=#{start}&count=#{count}").body
    @json = JSON.parse @json
  end
  #将数据插入数据库
  def insert_to_db
    @json["onlines"].each do |line|
      $has_it.push(line["id"])
      keys = []
      values = []
      line.each do |key, value|
        if key == 'tags'
          value = value.join('|')
        end
        keys.push('`' + key.to_s + '`')
        values.push("'" + value.to_s.gsub(/\'/, '') + "'")
      end
      keys = keys.join(',')
      values = values.join(',')
      odr = "INSERT into actives_data (#{keys}) VALUES (#{values})"
      puts "log: #{line["id"]} done."
      @sql.query(odr)
    end
    puts "log: #{$has_it.length} actives done."
  end
end

looper = API_Looper.new(100, 0, 100, 4)

worker = Worker.new('https://api.douban.com/v2/onlines')
looper.loop_get do |start, count, sleeptime|
  worker.get_active_info(start, count)
  worker.insert_to_db
  sleep sleeptime
end
