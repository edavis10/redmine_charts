module RedmineCharts
  module StackDataConverter

    def self.convert(index,name,values,labels)
      bar = OpenFlashChart::Bar.new
      bar.text = (name == '0') ? l(:charts_group_all) : name
      bar.colour = RedmineCharts::Utils.color(index)

      j = -1

      bar.values  = values.collect do |v|
        j += 1
        if v.is_a? Array
          d = OpenFlashChart::BarValue.new(v[0])
          d.set_value(v[0])
          d.set_tooltip("#{v[1]}<br>#{labels[j]}") unless v[1].nil?
          d
        else
          v
        end
      end

      bar
    end

  end
end
