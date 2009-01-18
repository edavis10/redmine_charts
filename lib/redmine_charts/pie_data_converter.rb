module RedmineCharts
  module PieDataConverter

    def self.convert(index,name,values,labels)
      pie = OpenFlashChart::Pie.new
      #pie.tooltip = get_hints
      pie.start_angle = 35
      pie.animate = true
      pie.colours = RedmineCharts::Utils.colors

      vals = values.collect do |v|
        if v.is_a? Array
          OpenFlashChart::PieValue.new(v[0], v[1])
        else
          v
        end
      end

      pie.values = vals
      pie
    end

  end
end
