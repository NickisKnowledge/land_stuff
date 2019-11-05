require 'csv'
require 'pry'

# file = CSV.read('Neighbor-Data-Indv.csv', header: :first_row, return_headers: true)
@csv_data = []
@headers = ["Last Name",
 "First Name",
 "Company",
 "Address",
 "City",
 "State",
 "Zip",
 "APN",
 "Type"]

 def correct_capitalize_name(lname, fname, co=nil)
   @new_row << lname.downcase.capitalize
   @new_row << fname.downcase.split.map(&:capitalize).join(' ')
   @new_row << co
 end

CSV.foreach('Neighbor-Data-Indv.csv') do |row|
  # binding.pry
  @new_row = []
  correct_capitalize_name(row[0], row[1], row[2])
  row[3..-1].each {|str| @new_row << str}
  @csv_data << @new_row
end


CSV.open('Indiv_neighbors.csv', 'w') do |csv|
  csv << @headers
  @csv_data.each {|arr| csv << arr}
end
