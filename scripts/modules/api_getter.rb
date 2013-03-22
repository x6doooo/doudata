#循环控制
class API_Looper
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

class API_getter
  attr_accessor :https, :uri
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
end
