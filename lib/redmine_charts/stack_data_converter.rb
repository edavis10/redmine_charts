module RedmineCharts
  module StackDataConverter

    include GLoc

    def self.convert(chart, data)
      tooltip = OpenFlashChart::Tooltip.new
      tooltip.set_hover()

      chart.set_tooltip(tooltip)

      bar = OpenFlashChart::BarStack.new
      bar.colours = RedmineCharts::Utils.colors

      keys = []
      values = []

      data[:sets].each_with_index do |set,i|
        set[1].each_with_index do |v,j|
          values[j] ||= []
          values[j][i] = if v.is_a? Array
            d = OpenFlashChart::BarStackValue.new(v[0], RedmineCharts::Utils.color(i))
            d.set_tooltip(v[1]) unless v[1].nil?
            d
          else
            v
          end
        end
        keys << {:colour => RedmineCharts::Utils.color(i), :text => set[0], :"font-size" => 10}
      end

      keys << {:colour => RedmineCharts::Utils.color(values.size), :text => l(:charts_deviation_group_estimated), :"font-size" => 10}

      bar.values = values
      bar.set_keys(keys)

      chart.add_element(bar)

      if data[:horizontal_line]
        shape = OpenFlashChart::Shape.new(RedmineCharts::Utils.color(values.size))
        shape.values = [
          OpenFlashChart::ShapePoint.new(-0.45, data[:horizontal_line]),
          OpenFlashChart::ShapePoint.new(-0.55 + values.size, data[:horizontal_line]),
          OpenFlashChart::ShapePoint.new(-0.55 + values.size, data[:horizontal_line] + 1),
          OpenFlashChart::ShapePoint.new(-0.45, data[:horizontal_line] + 1),
        ]
        chart.add_element(shape)
      end
    end

  end
end

# Fixes error with BarStackValue is OpenFlashChart ruby library
module OpenFlashChart
  class BarStackValue < Base
    def initialize(val,colour, args={})
      @val    = val
      @colour = colour
      super args
    end
  end
end

