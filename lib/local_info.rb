# -*- coding: utf-8 -*-
require 'open-uri'
require 'nokogiri'

class LocalInfo
  WW_URL = 'http://weather.livedoor.com/forecast/rss/warn/'

  def self.get_weather_warnings(id)
    doc = ""
    messages = []
    pref = "%02d" % id
    if pref == "01" then
      pref = "01b" # FIXME
    end

    begin
      doc = Nokogiri::XML(open(WW_URL + pref + '.xml').read)
      doc.xpath('//item/description').each {|node|
        messages.push(node.text) unless /livedoor/.match(node.text)
      }
    rescue
      messages = nil
    end
    messages
  end

  def self.get_google_news(pref_name)
    return LocalInfo::find_cse(pref_name+" ニュース",pref_name)
  end

  def self.get_hobby_news(hobby)
    hobby_result = LocalInfo::find_cse(hobby,hobby)
    hobbys = []
    if !hobby_result.has_key?("error") && !hobby_result["items"].blank? then
      hobby_result["items"].each do |a_news|
        #にっぽんもぎたて便の場合は返却する配列の先頭に挿入する
        if a_news["link"].include?("g=jfn") then
          hobbys.unshift(a_news)
        else
          #通常ニュースの場合は返却配列の末尾に挿入する
          hobbys.push(a_news)
        end
      end
      hobby_result["items"] = hobbys
    end
    return hobby_result
  end

  def self.find_cse(search_text,error_preffix)
    result = GoogleCustomSearchApi.search(search_text)
    if result.has_key?("error") || result["items"].blank? then
      result["error"] = error_preffix + "に関するニュースは見つかりませんでした"
    end
    return result
  end
end
