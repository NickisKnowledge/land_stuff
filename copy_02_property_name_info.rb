require 'csv'
require 'pry'

# file = CSV.read('Neighbor-Data-Indv.csv', header: :first_row, return_headers: true)
@csv_data = []
@neighbhor_headers = ["Last Name", "First Name", "Company", "Address", "City",
 "State", "Zip", "APN", "Type"]

@headers = [
  "APN",
  "Last Name",
  "First Name",
  "Company",
  "Type",
  "Address",
  "City",
  "State",
  "Zip",
  "Property County",
  "Property City",
  "Property State",
  "Property Zip",
  "Market Value",
  "Property Size",
  "Short legal description",
  "Tags"``
]

@acronyms = ['LLC', 'LC', 'LLLP', 'LP', 'L/P', 'LLP', 'PRTSHP', 'PARTNER', 'LTD', 'INC','TRS', 'TR', 'IRA','CO', 'TRE']

def correct_capitalize_name(lname, fname, co=nil)
  unless co
    # use to cap owner names w/or w/out commas ~ neighbor list
    split_name1_by = (lname.scan(/,/).any?) ? ', ' : ' '
    split_name2_by = (fname.scan(/,/).any?) ? ', ' : ' '

    arr_lname = lname.downcase.split(split_name1_by).map do |str|
      #additional check for names w/slashes need property casing
      if str.match?(/\//)
        str.split('/').map(&:capitalize).join('/')
      else
        str.split.map(&:capitalize).join(' ')
      end
    end

    arr_fname = fname.downcase.split(split_name2_by).map do |str|
      if str.match?(/\//)
        str.split('/').map(&:capitalize).join('/')
      else
        str.split.map(&:capitalize).join(' ')
      end
    end

    prop_lname = split_name1_by.scan(/,/).any? ? arr_lname.join(', ') : arr_lname.join(' ')
    prop_fname = split_name2_by.scan(/,/).any? ? arr_fname.join(', ') : arr_fname.join(' ')

    @new_row << prop_lname
    @new_row << prop_fname
    @new_row << nil
  else
    o_name = co.downcase.split
    o_name.map! do |str|
      if str.upcase.match?(/(L L C)|(L P)|(L C)|^ET$|^AL$/) || @acronyms.include?(str.upcase)
        str.upcase
      else
        str.capitalize
      end
    end
    proper_co = o_name.join(' ')
    2.times {@new_row << nil }
    @new_row << proper_co
  end

end

def proper_cap_addy_n_city(addy, city)
  address = addy.downcase.split
  address.map! {|str| str.match?('po') ? str.upcase : str.capitalize}
  @new_row << address.join(' ')
  @new_row << city.downcase.split.map(&:capitalize).join(' ')
end

# csv_data = CSV.open('Neighbors - Elmiara-Prop.csv', 'r', headers: :first_row)
csv_data = CSV.open('PinellasList - IndividualOwners.csv', 'r', headers: :first_row)

counter = 1
csv_data.each do |row|
  # binding.pry
  @new_row = [row.field('APN')]
=begin
# NONE Neighbor CSVs
  correct_capitalize_name(row.field('Last Name'), row.field('First Name'), row.field('Company'))

  # ["Address", "City", "State", "Zip", "Property County", "Property City",
  #    "Property State", "Property Zip", "Market Value", "Property Size",
  #    "Short legal description"]

  @headers[4..-2].each {|col_name| @new_row << row.field(col_name)}
  @new_row << '20191113 - FL - Pinellas Cty'
=end

  # binding.pry
  correct_capitalize_name(row.field('Last Name'), row.field('First Name'), row.field('Company'))
  proper_cap_addy_n_city(row.field('Address'), row.field('City'))
  @neighbhor_headers[6..-1].each {|col_name| @new_row << row.field(col_name)}
  @csv_data << @new_row

  # incase there's an issues w/a row will know easier to find row
  counter += 1
  puts counter
end


CSV.open('Proper_Name_Info.csv', 'w') do |csv|
  csv << @headers
  @csv_data.each {|arr| csv << arr}
end
