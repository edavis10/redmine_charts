module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter < AbstractAdapter

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

    end
  end
end