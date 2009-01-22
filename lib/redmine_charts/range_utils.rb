module RedmineCharts
  module RangeUtils

    include GLoc

    @@in_types = [ :days, :weeks, :months ]

    def self.in_options
      @@in_options ||= @@in_types.collect { |i| [l("charts_show_last_#{i}".to_sym), i.to_s] }
    end
    
    def self.set_params(params)     
      params[:range_steps] = 10 if params[:range_steps].blank?
      params[:range_offset] = 1 if params[:range_offset].blank?
      params[:range_in] = :weeks if params[:range_in].blank?
    end

    def self.from_params(params)
      {
        :steps => Integer(params[:range_steps]),
        :offset => Integer(params[:range_offset]),
        :in => params[:range_in].to_sym
      }
    end

    def self.prepare_range(range, column = "created_on")
      dates = []

      range[:steps].times do |i|
        dates[i] = get_times(range[:steps],range[:offset],i,range[:in])
      end

      keys = []
      labels = []

      range[:steps].times do |i|
        keys[i] = dates[i][0].strftime("%Y%m%d")
        labels[i] = get_label(dates[i][0], dates[i][1], range[:in])
      end

      sql = ActiveRecord::Base.format_date(range[:in], column)

      {
        :date_from => dates[0][0].to_date,
        :date_to => dates[dates.size-1][1].to_date,
        :labels => labels,
        :keys => keys,
        :dates => dates,
        :steps => range[:steps],
        :sql => sql
      }
    end

    private

    def self.get_label(from, to, type)
      if type == :months
        return from.strftime("%b %y")
      elsif type == :days
        return from.strftime("%d %b %y")
      else
        year_from = from.strftime("%y")
        month_from = from.strftime("%b")
        day_from = from.strftime("%d").to_i

        year_to = to.strftime("%y")
        month_to = to.strftime("%b")
        day_to = to.strftime("%d").to_i # - 1

        if year_from != year_to
          return "#{day_from} #{month_from} #{year_from} - #{day_to} #{month_to} #{year_to}"
        elsif month_from != month_to
          return "#{day_from} #{month_from} - #{day_to} #{month_to} #{year_from}"
        else
          return "#{day_from} - #{day_to} #{month_from} #{year_from}"
        end
      end
    end

    def self.get_times(steps, offset, i, type)
      if type == :months
        time = ((steps*offset)-i-1).send(type).ago
        [
          Time.mktime(time.year, time.month, 1, 0, 0, 0),
          Time.mktime(time.year, time.month, get_days_in_month(time.year, time.month), 23, 59, 59)
        ]
      elsif type == :days
        time = ((steps*offset)-i-1).send(type).ago
        [
          Time.mktime(time.year, time.month, time.day, 0, 0, 0),
          Time.mktime(time.year, time.month, time.day, 23, 59, 59)
        ]
      else
        time = ((steps*offset)-i-1).send(type).ago
        day_of_week = time.strftime('%w').to_i - 1
        day_of_week = 7 if day_of_week < 0
        time -= day_of_week.days
        time2 = time + 6.days
        [
          Time.mktime(time.year, time.month, time.day, 0, 0, 0),
          Time.mktime(time2.year, time2.month, time2.day, 23, 59, 59)
        ]
      end
    end

    def self.get_days_in_month(year, month)
      if month == 2 and ((year % 4 == 0 and year % 100 != 0) or (year % 400 == 0))
        29
      else
        [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month - 1]
      end
    end
    
  end
end
