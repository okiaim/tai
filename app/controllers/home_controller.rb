class HomeController < ApplicationController
  def top
    @stylesheet = "home"
    require "date"
    require "./CgiDecode.rb"
    ENV["TZ"] = "Asia/Tokyo"

    t = Time.current

    y = t.year
    m = t.month                    
                         
    t = Date.new(y,m,-1)
    #最終日のインスタンス作成
    selected_final_day = t.day
    selected_first_wday = Date.new(y,m,1).wday
    selected_total_days = (1 .. selected_final_day).to_a
    
    l_t = Date.new(y,m,-1).prev_month(1)
    last_final_day = Date.new(l_t.year,l_t.month,-1).day
    last_first_wday = Date.new(l_t.year,l_t.month,1).wday

    n_t = Date.new(y,m,-1).next_month(1)
    next_first_wday = Date.new(n_t.year,n_t.month,1).wday
    
    lastweek_first_day = last_final_day - selected_first_wday + 1
    lastweek_total_days = (lastweek_first_day .. last_final_day).to_a
    #先月の最終週の配列
    selected_lastweek_first_day = selected_final_day - next_first_wday + 1
    selected_lastweek_total_days = (selected_lastweek_first_day .. selected_final_day).to_a
    #今月の最終週の配列
    c = 7 - selected_lastweek_total_days.size
    next_firstweek_days = (1 .. c).to_a
    #来月の最初の週の配列

    whats_last_month = [l_t.month]*lastweek_total_days.size
    whats_selected_month = [t.month]*selected_total_days.size
    whats_next_month = [n_t.month]*next_firstweek_days.size

    whats_month = whats_last_month + whats_selected_month +whats_next_month
    #何月か配列に

    whats_last_year = [l_t.year]*lastweek_total_days.size
    whats_selected_year = [t.year]*selected_total_days.size
    whats_next_year = [n_t.year]*next_firstweek_days.size

    whats_year = whats_last_year + whats_selected_year + whats_next_year
    #何年か配列に

    days = lastweek_total_days+selected_total_days+next_firstweek_days

    @days = whats_year.zip(whats_month,days)
    #何年、何月、何日の二次元配列
    @table_cel_color = []
    @days.each do |day|
      if day[1] == m 
        @table_cel_color.push("table-default")
      else
        @table_cel_color.push("table-secondary")         
      end
    end
     @z = @table_cel_color
    
  end
end
