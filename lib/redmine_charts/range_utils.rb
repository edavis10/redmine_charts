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

    def self.count_range(range, first_time)
      case range[:in]
      when :weeks
        strftime_i = "%U"
        items_in_year = 52
      when :months
        strftime_i = "%m"
        items_in_year = 12
      else
        strftime_i = "%j"
        items_in_year = 366
      end

      first = first_time.strftime(strftime_i).to_i + first_time.strftime('%Y').to_i * items_in_year
      now = Time.now.strftime(strftime_i).to_i + Time.now.strftime('%Y').to_i * items_in_year

      range[:steps] = now - first + 4
      range[:offset] = 1
      range
    end

    def self.prepare_range(range, column = "created_on")
      case range[:in]
      when :weeks
        strftime_i = "%U"
      when :months
        strftime_i = "%m"
      else
        strftime_i = "%j"
      end

      from = times_ago(range[:steps],range[:offset],0,range[:in])
      to = times_ago(range[:steps],range[:offset]-1,0,range[:in])

      dates = []
      labels = []

      range[:steps].times do |i|
        labels[i] = label(range[:steps],range[:offset],i,range[:in])
        dates[i] = times_ago(range[:steps],range[:offset],i+1,range[:in])
      end

      diff = from.strftime(strftime_i).to_i + from.strftime('%Y').to_i
      sql = ActiveRecord::Base.format_date(range[:in], column, diff)

      [from, to, labels, range[:steps], sql, dates]
    end

    def self.label(steps, offset, i, type)
      time = times_ago(steps,offset,i,type)

      if type == :months
        return time.strftime("%b %y")
      elsif type == :days
        return time.strftime("%d %b %y")
      else
        year = time.strftime("%y")
        month = time.strftime("%b")
        day = time.strftime("%d").to_i

        time2 = times_ago(steps,offset,i+1,type)

        year2 = time2.strftime("%y")
        month2 = time2.strftime("%b")
        day2 = time2.strftime("%d").to_i - 1

        if year2 != year
          return "#{day} #{month} #{year} - #{day2} #{month2} #{year2}"
        elsif month2 != month
          return "#{day} #{month} - #{day2} #{month2} #{year}"
        else
          return "#{day} - #{day2} #{month} #{year}"
        end
      end
    end

    def self.times_ago(steps, offset, i, type)
      ((steps*offset)-i-1).send(type).ago
    end

  end
end
