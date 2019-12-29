require 'pry'
require 'csv'

@csv_data = []

@headers = [
   "APN",
   "Last Name",
   "First Name",
   "Company",
   "Type",
   "OWN_NAME", # ONLY when still need to formate owner name info
   "Property County",
   "Market Value",
   #"LND_SQFOOT", # ONLY FOR FL COUNTIES
   "Property Size",
   "Short Legal Description",
   "Tags",
   "Address",
   "City",
   "State",
   "Zip",
   "Property Address",
   "Property City",
   "Property State",
   "Property Zip",
 ]

def formate_cit_st_zip(mail_info)
  # find words with exactly TWO capital letters
  # binding.pry if mail_info.nil?
   state = mail_info.match(/\b[A-Z]{2}\b/)

  unless state.nil?
    state = state[0]
    # need to add comma in to seperate city & stat
    # delete anything that's NOT a word or number
    parsed_info = mail_info.split(/\b/).delete_if{|txt| !txt.match?(/[a-zA-Z]|\d/)}
    # get index of state
    idx = parsed_info.index(state)
    # find all text before state value
    city_txt = parsed_info[0...idx].join(' ')

    # add city info into arr
    @new_row << city_txt
    # add state
    @new_row << state
    # add '-' btw 9 digit zip codes pull everything after state idx
    zip = parsed_info[(idx+1)..-1].join('-')
    # join all text after state value
    @new_row << zip
  else
    @new_row << mail_info + ', CHECK RESULTS'
  end
end

csv_data = CSV.open('ClayList - HeaderCorrection.csv', 'r', headers: :first_row)

counter = 1
csv_data.each do |row|
  @new_row = []

  @headers[0..9].each {|col_name| @new_row << row.field(col_name)}
  @new_row << '20191205 - FL - Clay Cty'

  # formate owner address info, 1 big string
  # row.field('Owner Address') #=> "363 HIGDON ROAD\r\nJACKSONVILLE, FL 32234-3206"
  addy_info = row.field('Owner Address').split(/\r\n/)
  #=> addy_info = ["363 HIGDON ROAD", "JACKSONVILLE, FL 32234-3206"]

  @new_row << addy_info.first
  formate_cit_st_zip(addy_info.last)

  # binding.pry
  # add property address
  @new_row << row.field('Location Street')
  formate_cit_st_zip(row.field('Location City, State, Zip'))

  @csv_data << @new_row

  # incase there's an issues w/a row will know easier to find row
  counter += 1
  puts counter
end


CSV.open('Formatted_Addresses.csv', 'w') do |csv|
  csv << @headers
  @csv_data.each {|arr| csv << arr}
end
