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
        strftime_i = "%W"
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
        strftime_i = "%W"
        strftime_f = "%Y-%W"
      when :months
        strftime_i = "%m"
        strftime_f = "%Y-%m"
      else
        strftime_i = "%j"
        strftime_f = "%Y-%m-%d"
      end

      from = times_ago(range[:steps],range[:offset],0,range[:in])
      to = times_ago(range[:steps],range[:offset]-1,0,range[:in])

      dates = []
      x_labels = []

      range[:steps].times do |i|
        x_labels[i] = times_ago(range[:steps],range[:offset],i,range[:in]).strftime(strftime_f)
        dates[i] = times_ago(range[:steps],range[:offset],i+1,range[:in])
      end

      diff = from.strftime(strftime_i).to_i + from.strftime('%Y').to_i
      sql = ActiveRecord::Base.format_date(range[:in], column, diff)

      [from, to, x_labels, range[:steps], sql, dates]
    end

    def self.times_ago(steps, offset, i, type)
      ((steps*offset)-i-1).send(type).ago
    end

  end
end
