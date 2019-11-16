require 'pry'
require 'csv'


# binding.pry
# csv = CSV.read('PinellasCoList - OutCty Co-10k+Owners.csv', headers: :first_row, return_headers: true)
csv = CSV.read('Sarasota IndvParcels - Out-Cty.csv', headers: :first_row, return_headers: true)

counter = 1
csv.delete_if do |row|
  # binding.pry
  unless row.header_row?
    # binding.pry
    counter += 1
    puts counter
    row.field('Market Value').to_i > 100000
  end
end

CSV.open("RecordsLessThan100k.csv","wb") do |csv_out|
    csv.each{ |row| csv_out << row }
end

#filter code minic
# https://www.ruby-forum.com/t/csv-delete-an-entry/242928/3
