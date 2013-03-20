#encoding: utf-8
require 'RubyGems'
require 'mysql'
require 'json'

#对创建时间进行分析

class Created_getter
  attr_accessor :sql, :date_src, :day_src, :time_src
  def initialize
    @sql = Mysql.new('localhost', 'root', '', 'test')
    @date_src = []
    @time_src = []
    @day_src = []
  end
  def get_src_data
    @data = @sql.query('SELECT created FROM actives_data ORDER BY created').to_a
  end
  def format_date_and_time
    @data.each do |v|
      v = v[0]
      @date_src.push(v[0..9])
      @day_src.push(v[5..9])
      @time_src.push(v[11..15])
    end
  end
end

class Formatter
  attr_accessor :data, :result
  def initialize(data)
    @data = data
  end
  def uniq_count
    data_uniq = @data.uniq
    @result = data_uniq.collect do |v|
      {"val" => v, "count" => @data.count(v)}
    end
  end
  def resort
    @result = @result.sort { |a, b| a["val"] <=> b["val"]}
  end
end

created_getter = Created_getter.new
created_getter.get_src_data
created_getter.format_date_and_time

date_formatter = Formatter.new(created_getter.date_src)
date_formatter.uniq_count

day_formatter = Formatter.new(created_getter.day_src)
day_formatter.uniq_count
day_formatter.resort

time_formatter = Formatter.new(created_getter.time_src)
time_formatter.uniq_count
time_formatter.resort

all = {
  "date" => date_formatter.result,
  "day" => day_formatter.result,
  "time" => time_formatter.result
}

File.open('../../json/onlines/created.json', 'w') { |file| file.write(all.to_json) }
