#encoding: utf-8
require 'RubyGems'
require 'net/https'
require 'mysql'
require 'json'

#获取豆瓣线上活动数据

$has_it = []

#循环控制
class Looper
  attr_accessor :total, :start, :count, :sleep
  def initialize(total, start, count, sleep)
    @total = total #总计要取多少条活动
    @start = start #开始位置
    @count = count #每次取多少条
    @sleep = sleep #豆瓣API有频次限制，通过sleep避免请求过快
  end
  def loop_get
    (@start...@total).step(@count)do |start|
      yield(start, @count, @sleep)
    end
  end
end

#获取数据
class Worker
  attr_accessor :https, :uri, :json, :sql
  #初始化接口和数据库
  def initialize(uri)
    @uri = URI(uri)
    @https = init_https(@uri)
    @sql = Mysql.new('localhost', 'root', '', 'test')
  end
  #豆瓣接口是https，这里要设置Net::HTTP的协议
  def init_https(uri)
    https = Net::HTTP.new(uri.host, uri.port)
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    https.use_ssl = true
    https
  end
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

looper = Looper.new(82800, 0, 100, 4)
worker = Worker.new('https://api.douban.com/v2/onlines')
looper.loop_get do |start, count, sleeptime|
  worker.get_active_info(start, count)
  worker.insert_to_db
  sleep sleeptime
end
