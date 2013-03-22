#encoding: utf-8
require 'RubyGems'
require 'mysql'
require 'json'

class Tag_counter
  attr_accessor :sql, :tags, :length, :target_number, :records
  def initialize(num)
    @sql = Mysql.new('localhost', 'root', '', 'test')
    @tags = []
    @length = 0
    @target_number = num
  end
  def go
    @records = get_records
    loop_check
    into_db
  end
  def get_records
    @sql.query("SELECT tags,participant_count,photo_count,liked_count,recs_count FROM actives_data LIMIT #{@target_number}").to_a
  end
  def loop_check
    while !records.empty?
      rd = records.pop
      check_it(rd)
      printf "\r count: %.2f %%  tags_count: #{tags.length}  pass: #{@target_number-records.length}  less: #{records.length}" , (@target_number - records.length).to_f/@target_number.to_f * 100
      $stdout.flush
    end
  end
  def check_it(val)
    val[0] = val[0].gsub(/[\s,.!@\#$\%^&。，；：#！？——=\+\^‘’“”{}！￥~、]/u,'|').downcase.split('|')
    val[0].each do |v|
      pos = @tags.index{ |rd| rd[0] == v }
      if pos
        update_it(v, val, pos)
      else
        insert_it(v, val)
      end
    end
  end
  def update_it(v, val, pos)
    (1..4).each do |i|
      @tags[pos][i] = @tags[pos][i].to_i + val[i].to_i
    end
  end
  def insert_it(v, val)
    @tags.push([v, val[1], val[2], val[3], val[4]])
  end
  def into_db
    idx = 0
    puts "\n tags_count = #{@tags.length}"
    @tags.each do |rd|
      @sql.query("INSERT into actives_tags (tag,participant_count,photo_count,liked_count,recs_count) VALUES ('#{rd[0]}', #{rd[1]}, #{rd[2]}, #{rd[3]}, #{rd[4]})")
      idx += 1
      printf "\r insert : %.2f %% ", idx/@tags.length.to_f * 100
    end
  end
end

counter = Tag_counter.new(82800)
counter.go
