module RedmineCharts
  module DateFormat

    case ActiveRecord::Base.connection.adapter_name
    when /mysql/i
      def format_date(format_in, column_name, diff_value)
        case format_in
        when :weeks
          format_in = "%u"
        when :months
          format_in = "%m"
        else
          format_in = "%j"
        end
                                                  
        "(DATE_FORMAT('#{format_in}', #{column_name}) + DATE_FORMAT('%Y', #{column_name}) - #{diff_value})"
      end
    when /postgres.*/i
      def format_date(format_in, column_name, diff_value)
        case format_in
        when :weeks
          format_in = "week"
        when :months
          format_in = "month"
        else
          format_in = "doy"
        end
                                                                      
        "(date_part('#{format_in}', #{column_name}) + date_part('year', #{column_name}) - #{diff_value})"
      end
    else
      def format_date(format_in, column_name, diff_value)
        case format_in
        when :weeks
          format_in = '%W'
        when :months
          format_in = '%m'
        else
          format_in = '%j'
        end

        "(strftime('#{format_in}', #{column_name}) + strftime('%Y', #{column_name}) - #{diff_value})"
      end
    end

  end
end

ActiveRecord::Base.send(:extend, RedmineCharts::DateFormat)
