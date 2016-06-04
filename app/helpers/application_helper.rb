module ApplicationHelper

  def redirect_back_or(default = nil)
    redirect_to r and return if r = session.delete(:return_to)
    begin
      redirect_to :back
    rescue ActionController::RedirectBackError
      redirect_to default
    end
  end

  def timeago(time, timestring = nil)
    content_tag(:time, class: 'timeago', datetime: time.iso8601) do
      timestring ? timestring : time.to_s(:friendly_long)
    end
  end

  def flash_messages(flash)
    c = flash.select{ |k, v| k.in?(['notice', 'alert']) }.map { |k, v| content_tag(:div, v, class: "#{k.downcase}") }.compact
    %|<div id="flash-container">#{c.join}</div>|.html_safe
  end


end
