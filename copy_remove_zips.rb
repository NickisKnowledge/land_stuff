require 'pry'
require 'csv'

# zips = %w(50028	Baxter	Jasper County
# 50054	Colfax	Jasper County
# 50127	Ira	Jasper County
# 50135	Kellogg	Jasper County
# 50137	Killduff	Jasper County
# 50153	Lynnville	Jasper County
# 50168	Mingo	Jasper County
# 50170	Monroe	Jasper County
# 50208	Newton	Jasper County
# 50228	Prairie City	Jasper County
# 50232	Reasnor	Jasper County
# 50251)

zips = %w(50044	Bussey	Marion County
50057	Columbia	Marion County
50062	Dallas	Marion County
50116	Hamilton	Marion County
50119	Harvey	Marion County
50138	Pershing	Marion County
50138	Knoxville	Marion County
50163	Melcher Dallas	Marion County
50163	Melcher	Marion County
50214	Otley	Marion County
50219	Pella	Marion County
50225	Pleasantville	Marion County
50252	Swan	Marion County
50256	Tracy	Marion County
).collect {|str| match = str.match(/[\d]{5}/); match[0] if !match.nil?}.compact!.uniq

# csv = CSV.read('JasperCty-Owner-Seperated.csv', headers: :first_row, return_headers: true)
csv = CSV.read('MarionCty- Seperated-CityStZip.csv', headers: :first_row, return_headers: true)
csv.by_row!
csv.delete_if do |row|
  # binding.pry
  unless row.header_row?
    # binding.pry
    zipcode = (row.field('Zip').match?(/-/)) ? (row.field('Zip').split('-').first) : row.field('Zip')
    zips.include?(zipcode)
  end
end

CSV.open("OutOfCountyRecords.csv","wb") do |csv_out|
    csv.each{ |row| csv_out << row }
end

#filter code minic
# https://www.ruby-forum.com/t/csv-delete-an-entry/242928/3
