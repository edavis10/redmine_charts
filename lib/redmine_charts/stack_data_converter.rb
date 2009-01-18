module RedmineCharts
  module StackDataConverter

    include GLoc

    def self.convert(chart, sets, labels)
      tooltip = OpenFlashChart::Tooltip.new
      tooltip.set_hover()
      
      chart.set_tooltip(tooltip)

      bar = OpenFlashChart::BarStack.new
      bar.colours = RedmineCharts::Utils.colors

      values = []

      sets.each_with_index do |set,i|
        set[1].each_with_index do |v,j|
          values[j] ||= []
          values[j][i] = if v.is_a? Array
            d = OpenFlashChart::BarStackValue.new(v[0], RedmineCharts::Utils.color(i))
            d.set_value(v[0])
            d.set_tooltip("#{v[1]}<br>#{labels[j]}") unless v[1].nil?
            d
          else
            v
          end
        end
      end

      bar.values = values

      chart.add_element(bar)
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

