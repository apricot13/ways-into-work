module AdvisorHelper
  def number_of_days_waiting(date)
    if date != Time.zone.today
      " - waiting #{pluralize((Time.zone.today - date).to_i, 'day')}"
    else
      ' - today'
    end
  end
end
