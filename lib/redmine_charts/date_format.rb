module RedmineCharts
  module DateFormat

    case ActiveRecord::Base.connection.adapter_name
    when /mysql/i
      def format_date(format, column)
        case format
        when :weeks
          "(case when cast(date_format(#{column}, '%d') as unsigned) <= cast(date_format(#{column}, '%w') as unsigned) then date_format(date_add(#{column}, interval - 7 day), '%Y%m%d') - date_format(#{column}, '%w') + 7 else date_format(#{column}, '%Y%m%d') - date_format(#{column}, '%w') end)"
        when :months
          "date_format(#{column}, '%Y%m01')"
        else
          "date_format(#{column}, '%Y%m%d')"
        end
      end
    when /postgresql/i
      def format_date(format, column)
        case format
        when :weeks
          "(case when date_part('days', #{column}) <= date_part('dow', #{column}) then cast(to_char(#{column} - interval '7 days','YYYYMMDD') as integer) - date_part('dow', #{column}) + 7 else cast(to_char(#{column},'YYYYMMDD') as integer) - date_part('dow', #{column}) end)"
        when :months
          "to_char(#{column},'YYYYMM01')"
        else
          "to_char(#{column},'YYYYMMDD')"
        end
      end
    when /sqlite/i
      def format_date(format, column)
        case format
        when :weeks
          "(case when cast(strftime('%d', #{column}) as 'integer') <= strftime('%w', #{column}) then strftime('%Y%m%d', date(#{column}, '-7 day')) - strftime('%w', #{column}) + 7 else strftime('%Y%m%d', #{column}) - strftime('%w', #{column}) end)"
        when :months
          "strftime('%Y%m01', #{column})"
        else
          "strftime('%Y%m%d', #{column})"
        end        
      end
    else
      raise "Unsupported adapter. Redmine Charts supports only SQLite, MySQL and PostgreSQL databases."
    end

  end
end

ActiveRecord::Base.send(:extend, RedmineCharts::DateFormat)