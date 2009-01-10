module ActiveRecord
  module ConnectionAdapters
    class AbstractAdapter

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
