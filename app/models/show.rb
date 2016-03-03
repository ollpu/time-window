class Show < ApplicationRecord
  def parts
    arr = []
    self.names.each_with_index do |n, i|
      arr.push({:name => n, :time => self.times[i]})
    end
    arr
  end
end
