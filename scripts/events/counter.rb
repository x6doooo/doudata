#encoding: utf-8
require 'RubyGems'
require 'mysql'
require 'json'


$sql = Mysql.new('localhost', 'root', '', 'test')

class GeoCounter
  attr_accessor :fields, :records
  def initialize
    @fields = ['geo', 'begin_time', 'end_time', 'participant_count']
  end
  def go
    get_all_records
    make_file
  end
  def get_all_records
    @records = $sql.query("SELECT #{@fields.join(',')} FROM events_bj ORDER BY begin_time").to_a
  end
  def make_file
    File.open('../../json/events/bj_heat.json', 'w') do |file|
      file.write(@records.to_json)
    end
  end
end

counter = GeoCounter.new
counter.go


