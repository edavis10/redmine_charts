module RedmineCharts
  module DataForStack

    def self.prepare_data(i,chart,name,values,labels)
      bar = OpenFlashChart::Bar.new
      bar.text = (name == '0') ? l(:charts_group_all) : name
      bar.colour = RedmineCharts::Utils.color(i)

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

      chart.add_element(bar)
    end

  end
end
