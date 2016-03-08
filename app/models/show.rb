require 'securerandom'
class Show < ApplicationRecord
  validate :validate_parts
  before_save :try_generate_urlid
  
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
    if @parts.present?
      @parts
    else
      @parts = []
      self.names.each_with_index do |n, i|
        @parts.push({:name => n, :time => self.times[i]})
      end
      @parts
    end
  end
  
  def title_human
    if title.present?
      title
    else
      "(no title)"
    end
  end
  
  def try_generate_urlid
    unless self.urlid.present?
      generate_urlid
    end
  end
  
  def generate_urlid
    self.urlid = SecureRandom.hex 8
  end
end
