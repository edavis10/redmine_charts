module RedmineCharts
  module PieDataConverter

    def self.convert(chart, data)
      tooltip = OpenFlashChart::Tooltip.new
      tooltip.set_hover()

      chart.set_tooltip(tooltip)

      data[:sets].each do |set|
        pie = OpenFlashChart::Pie.new
        pie.start_angle = 35
        pie.animate = true
        pie.colours = RedmineCharts::Utils.colors

        vals = []
        
        set[1].each_with_index do |v, index|
          if v.is_a? Array
            d = OpenFlashChart::PieValue.new(v[0], data[:labels][index])
            d.set_tooltip(v[1]) unless v[1].nil?
            vals << d
          else
            vals << v
          end
        end

        pie.values = vals

        chart.add_element(pie)
      end
    end

  end
end
