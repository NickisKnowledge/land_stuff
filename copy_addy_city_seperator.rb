require 'watir'
require 'nokogiri'
require 'httparty'
require 'pry'
require 'csv'

@headers = ['APN', 'Property County',	'Market Value', 'Property Size',	'Short Legal Description', 'Type', 'Company',	'Last Name', 'First Name', 'Tags', 'State', 'Zip', 'City', 'Address']
@csv_data = []

def csv_iterator(file)
  file.each_with_index do |row, i|
    # binding.pry
    unless row.header_row?
      row_info = []
      # add all other column data into row_to_arr
      @headers[0...-2].each do |col_name|
        row_info << row.field(col_name)
      end
      # @headers[0...-2].each do |col_name|
      # puts row.field(col_name)
      # end
      # get city, state, zip from CSV row
      address = row.field("Address") + " "
      bad_city = row.field("City")
      row_updated = po_boxes(address, bad_city, row_info)
       puts i

      # binding.pry
      # address += row.field("State") + " "
      # address += row.field("Zip") + " "
      # #save all other data into row
      # make a new row
# binding.pry
      # updated_row = gsearch_address(address, browser, row_info)
      @csv_data << row_updated

      # puts i
      if @csv_data.length.even?
        create_csv
        # binding.pry
        @csv_data.clear
      end
      # formate_cit_st_zip(data, row_info)
    else
      @csv_data << @headers
    end
    # binding.pry
  end
  create_csv
end

def po_boxes(addy, city, csv_row)
  # binding.pry
  nums = city.match(/(\d)+/) unless city.nil?
  if !nums.nil?
    csv_row << city.split(nums[0]).last
    csv_row << addy += nums[0]
  else
    nums = addy.match(/(\d)+/)[0]
    addy_parts = addy.split(nums)
    csv_row << addy_parts.last
    csv_row << addy_parts.first + ' '+ nums
  end
  csv_row
end
# def gsearch_address(addy, browser, row)
#   browser.goto 'google.com'
#   browser.text_field(name: 'q').set"#{addy}"
#   browser.send_keys :return
#
#   parsed_page = Nokogiri::HTML(browser.html)
#   prob_addy = parsed_page.css('div.desktop-title-content').text
#
#   unless prob_addy.empty?
#     binding.pry
#     full_addy =  parsed_page.css('a.gL9Hy')
#     city = full_addy.children[1].text.split.last
#     address = full_addy.text.split(city).first
#     st_zip = full_addy.text.split(city).last.split
#     row << city
#     row << st_zip[0]
#     row << st_zip[-1]
#     row << address
#   else
#     city_st_zip = parsed_page.css('span.desktop-title-subcontent').text
#     seperate_cit_st_zip = city_st_zip.gsub(',','').split
#     #  'City', 'State', 'Zip', 'Address
#     city = seperate_cit_st_zip.shift
#     # add city
#     row << city
#     # add state
#     row << seperate_cit_st_zip.shift
#     # add zip
#     row << seperate_cit_st_zip.shift
#     # prob_addy.downcase.gsub("#{city.downcase}",'').split.map(&:capitalize).join(' ')
#     # add in the address w/out the city attached, removing length of characters of city name
#     row << prob_addy[0...-city.length]
#     end
#   # binding.pry
#   row
# end


def create_csv
  CSV.open("generated.csv","a+") do |csv_out|
    # binding.pry
    # csv.by_row!
    @csv_data.each{ |row| csv_out << row }
  end
end

# webpage = Watir::Browser.new
# read_csv = CSV.read('test.csv', headers: :first_row, return_headers: true)
read_csv = CSV.read('POBOX-Jeff-Fix-City.csv', headers: :first_row, return_headers: true)
csv_iterator(read_csv)
