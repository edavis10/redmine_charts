module ActiveRecord
  module ConnectionAdapters
    class MysqlAdapter < AbstractAdapter

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

    end
  end
end
