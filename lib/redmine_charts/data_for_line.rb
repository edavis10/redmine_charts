module RedmineCharts
  module DataForLine

    def self.prepare_data(index,name,values,labels)
      line = OpenFlashChart::LineDot.new
      line.text = (name == '0') ? l(:charts_group_all) : name
      line.width = 2
      line.colour = RedmineCharts::Utils.color(index)
      line.dot_size = 2

      j = -1

      vals = values.collect do |v|
        j += 1
        if v.is_a? Array
          d = OpenFlashChart::Base.new
          d.set_value(v[0])
          if v[2]
            d.dot_size = 4
          end
          d.set_colour(RedmineCharts::Utils.color(index))
          d.set_tooltip("#{v[1]}<br>#{labels[j]}") unless v[1].nil?
          d
        else
          v
        end
      end

      line.values = vals
      line
    end

  end
end
