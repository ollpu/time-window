require 'securerandom' # Used for generating urlid

class Show < ApplicationRecord
  validate :validate_parts
  before_save :try_generate_urlid
  
  private def validate_parts # Validates data related to the parts
    if names.length != times.length
      errors.add(:parts, "Didn't find the same amount of names and times!")
    end
    times.each do |time|
      unless time.is_a? Integer
        errors.add(:times, "Time \"#{time}\" is of invalid format!")
      end
    end
  end
  
  def live? # Is the show live?
    live
  end
  
  # Return an array-hash of parts: [{:name, :time}, ...]
  # NOTE: Doesn't display changes if an array was previouslty generated for this instance
  def parts
    unless @parts.present? # If not previously generated
      @parts = []
      self.names.each_with_index do |n, i|
        @parts << {:name => n, :time => self.times[i]}
      end
    end
    @parts # Return the parts-array (either before or newly generated)
  end
  
  def title_human
    title || "(no title)"
  end
  
  def try_generate_urlid # Generate urlid if it's not present
    self.urlid ||= SecureRandom.hex 8
  end
  
  def generate_urlid # Force-generate urlid
    self.urlid = SecureRandom.hex 8
  end
end
