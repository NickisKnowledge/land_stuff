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
  "Tags"
]

def correct_capitalize_indiv_name(lname, fname)
  # use to cap owner names w/or w/out commas ~ neighbor list
  split_name1_by = (lname.scan(/,/).any?) ? ', ' : ' '
  split_name2_by = (fname.scan(/,/).any?) ? ', ' : ' '
  @new_row << lname.downcase.split(split_name1_by).map(&:capitalize).join(' ')
  @new_row << fname.downcase.split(split_name2_by).map(&:capitalize).join(' ')
end

csv_data = CSV.open('PinellasList - IndividualOwners.csv', 'r', headers: :first_row)

counter = 1
csv_data.each do |row|
  # binding.pry
  @new_row = [row.field('APN')]

  correct_capitalize_indiv_name(row.field('Last Name'), row.field('First Name'))

  # ["Address", "City", "State", "Zip", "Property County", "Property City",
  #    "Property State", "Property Zip", "Market Value", "Property Size",
  #    "Short legal description"]

  @headers[3..-2].each {|col_name| @new_row << row.field(col_name)}
  @new_row << '20191113 - FL - Pinellas Cty'
  @csv_data << @new_row

  # incase there's an issues w/a row will know easier to find row
  counter += 1
  puts counter
end


# neighbor CSVs
# csv.each do |row|
#   # binding.pry
#   @new_row = []
#   correct_capitalize_indiv_name(row.field('Last Name'), row.field('First Name'))
#   @neighbhor_headers[2..-1].each {|str| @new_row << row.field(col_name)}row.field(col_name)
#   @csv_data << @new_row
# end


CSV.open('Indiv_owners_proper_name.csv', 'w') do |csv|
  csv << @headers
  @csv_data.each {|arr| csv << arr}
end
