# -- coding: utf-8

class CrontabParser
  class Record
    attr_reader :line

    def initialize(line, options={})
      @line = line
      @options = options
    end

    def cmd
      times
      @cmd
    end

    def to_s
      @line
    end


    def should_run?(time)
      time.utc
      times[:min].include?(time.min) &&
        times[:hour].include?(time.hour) &&
        times[:day].include?(time.day) &&
        times[:month].include?(time.month) &&
        times[:week].include?(time.wday)
    end

    def next_run(time=Time.now.utc, times=times)
      raise ArgumentError, "The incoming time value is not set to UTC" unless time.utc?

      time = times[:future] if times.has_key?(:future)

      # clear the existing hours, seconds, and minutes so the UTC comparison is inline with the passed in time
      next_slot = Time.now.at_beginning_of_year.utc

      times[:min].each do |min|
        break if next_slot.min > time.min
        next_slot = next_slot.change(:min => min)
      end

      # puts "HOUR SLOTS: #{times[:hour]}"
      times[:hour].each do |hour|
        break if next_slot.hour >= time.hour && next_slot.min > time.min
        next_slot = Time.new(next_slot.year, next_slot.month, next_slot.day, hour, next_slot.min, 0, 0).utc
        # if the last hour option (the largest) is less than now, break at the first option since we're into the next day
        break if times[:hour].last < time.hour
      end

      # puts "Parsing days of month #{times[:day].to_s}"
      # if the last valid day is still numerically less than the current day_of_month, than just advance by one month before we do a comparison
      times[:day].each do |day_of_month|
        next_slot = Time.new(next_slot.year, next_slot.month, day_of_month, next_slot.hour, next_slot.min, next_slot.sec, 0).utc
        # if we've already passed today's slot then we _have_ to advance
        if next_slot.hour < time.hour && next_slot.day == time.day
          next
        elsif next_slot.day > time.day || times[:day].last < time.day
          break
        end
      end

      # puts "CALCULATED  : #{next_slot}"

      # puts "Months: #{times[:month]}"
      # assume we're going to run at least once this year...
      times[:month].each do |month|
        break if next_slot.month >= time.month # && next_slot > time
        next_slot = Time.new(next_slot.year, month, next_slot.day, next_slot.hour, next_slot.min, next_slot.sec, 0).utc
      end

      # weekdays, weekends, etc.
      if times[:week].size < 7
        # puts "Limiting days of week to #{times[:week]}"
        (0..6).each do
          next_slot = next_slot.advance(:days => 1) 
          if times[:week].last < next_slot.wday
            next
          elsif times[:week].include?(next_slot.wday)
            break
          end
        end
      end

      # if this is annual, then we can safely advance one year here if we've already passed this year's window
      if next_slot < time
        # puts "next_slot < time: #{next_slot} < #{time}"
        next_slot = next_slot.advance(:years => 1)
      end

      next_slot
    end

    def times
      @times ||= begin
        base = @line.strip.gsub(/#.*/, "").gsub(%r!^@(yearly|annually|monthly|weekly|daily|midnight|hourly)!){|m|
          case $1
          when 'yearly','annually'
            '0 0 1 1 *'
          when 'monthly'
            '0 0 1 * *'
          when 'weekly'
            '0 0 * * 0'
          when 'daily','midnight'
            '0 0 * * *'
          when 'hourly'
            '0 * * * *'
          end
        }.strip
        min,hour,day,month,week,@cmd = *base.split(/[\t\s]+/, 6)
        base = [min,hour,day,month,week].join(" ")
        if week.nil?
          if @options[:silent]
            return nil
          else
            raise "invalid line #{@line}"
          end
        end
        {
          :month => TimeParser.parse(month, 1, 12),
          :day => TimeParser.parse(day, 1, 31),
          :hour =>  TimeParser.parse(hour, 0, 23),
          :min => TimeParser.parse(min, 0, 59),
          :week => TimeParser.parse(week, 0, 6),
        }
      end
    end
  end
end
