# frozen_string_literal: true

require_relative "./csvnormalizer/version"
require 'thor'
require 'csv'
require 'date'



module Csvnormalizer
  class Error < StandardError; end
  class CLI < Thor
    desc "[Input CSV] [Normalized CSV]", "Enter input CSV name followed by the desired normalized CSV name"
    def CLI.exit_on_failure?
      true
    end
    def normalize(icsv,ncsv)

custom_converter = lambda{ |value, field_info|
case field_info.header
when 'Timestamp'
  value = value + " PST"
ptime = DateTime.strptime(value, "%m/%d/%y %H:%M:%S %P %Z")
etime= ptime + (3.0/24)

when 'ZIP'
  if value.to_s.length >4
    value.to_s
  else
    ('%5.5s' % value.to_s).gsub(' ', '0')
    
  end
when 'FullName'
  value.upcase
when 'FooDuration'
  h, m, s = value.split(":").map(&:to_f)
  h %= 24
  (((h * 60) + m) * 60) + s  
when 'BarDuration'
  h, m, s = value.split(":").map(&:to_f)
  h %= 24
  (((h * 60) + m) * 60) + s
else
  value
end
}

      table = CSV.parse(File.read(icsv).scrub, encoding: 'UTF-8', headers: true, converters: [custom_converter])
      table.each do |row|
       row['TotalDuration'] = row['FooDuration'] + row['BarDuration']
      end
      
      File.write(ncsv, table)
    end
  end
end
