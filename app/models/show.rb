class Show < ApplicationRecord
  validate :validate_parts
  
  private def validate_parts
    if names.length != times.length
      errors.add(:parts, "Didn't find the same amount of names and times!")
    end
    times.each do |time|
      unless time.is_a? Integer
        errors.add(:times, "Time \"#{time}\" is of invalid format!")
      end
    end
  end
  
  def live?
    live
  end
  
  def parts
    arr = []
    self.names.each_with_index do |n, i|
      arr.push({:name => n, :time => self.times[i]})
    end
    arr
  end
end
