class TimeSpec
  attr_reader :to, :from, :time_type, :date_type
  
  def initialize(hash = nil)
    hash = {} if hash.nil?
    hash = hash.with_indifferent_access
    @to = if hash.has_key? :to
      whatever_to_dt hash[:to]
    else
      Time.zone.now
    end
   
    @from = if hash.has_key? :from
     whatever_to_dt hash[:from]
    else
      Time.zone.now
    end
    if hash.has_key? :date
      self.date = hash[:date]
    end
    if hash.has_key? :time
      self.time = hash[:time]
    end
    
    if hash.has_key? :time_type
      @time_type = hash[:time_type]
    end
    if hash.has_key? :date_type
      @date_type = hash[:date_type]
    end
  end

  def date=(val)
    self.date_from, self.date_to, @date_type = DateParser.parse val
  end

  def date_from
    @from.to_date
  end

  def date_from=(date)
    @from = @from.change year: date.year, month: date.month, day: date.day
  end

  def date_to
    @to.to_date
  end

  def date_to=(date)
    @to = @to.change year:date.year, month: date.month, day: date.day
  end

  def time=(val)
    self.time_from, self.time_to, @time_type = TimeParser.parse(val)
  end

  def time_from
    @from.hour*60+@from.min
  end

  def time_from=(minutes)
    @from = @from.change hour: minutes/60, min: minutes%60
  end

  def time_to
    @to.hour*60+@to.min
  end

  def time_to=(minutes)
    @to = @to.change hour: minutes/60, min: minutes%60
  end
  
  def mongoize
    {from: (dt_to_t @from), to: (dt_to_t @to), time_from: time_from, time_to: time_to, time_type: time_type, date_type: date_type}
  end
               
  def as_json(*args)
    {date: {from: date_from, to: date_to, type: date_type}, time: {from: humanize(time_from), to: humanize(time_to), type: time_type}}
  end
  
  class << self
    def demongoize(object)
      TimeSpec.new(object)
    end
    
    def mongoize(object)
      case object
      when TimeSpec then object.mongoize
      when Hash then TimeSpec.new(object).mongoize
      else object
      end
    end
    
    def evolve(object)
      case object
      when TimeSpec then object.mongoize
      else object
      end
    end
  end
  
private
  def dt_to_t(dt)  
    dt.utc
  end
  def whatever_to_dt(dt)
    case dt                           
    when DateTime then dt.utc.in_time_zone
    when Time then dt.utc.in_time_zone
    when String then Time.zone.parse dt
    else dt
    end
  end
  def humanize(time)
    hour = time/60
    minute = time%60
    "%02d:%02d" % [hour, minute]
  end
end