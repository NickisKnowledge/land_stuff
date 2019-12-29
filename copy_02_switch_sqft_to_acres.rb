require 'csv'
require 'pry'

# file = CSV.read('Neighbor-Data-Indv.csv', header: :first_row, return_headers: true)
@csv_data = []

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
  "Short legal description",
  "Tags",
  'Property Size'
]

def change_sqft_to_acres(sqFt)
  # binding.pry
  acres = (sqFt.to_i / 43560.0).round(2)
  @new_row << acres
end

csv_data = CSV.open('LakeList - FormattedOwners.csv', 'r', headers: :first_row)

counter = 1
csv_data.each do |row|
  @new_row = []
  # binding.pry
  @headers[0..-2].each {|col_name| @new_row << row.field(col_name)}
  change_sqft_to_acres(row.field('LND_SQFOOT'))
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


CSV.open('AcrageCalculations.csv', 'w') do |csv|
  csv << @headers
  @csv_data.each {|arr| csv << arr}
end
