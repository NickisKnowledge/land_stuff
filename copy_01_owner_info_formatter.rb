require 'pry'
require 'csv'
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

@co_keywords = ['LLC', 'LC', 'LLLP', 'LP', 'L/P', 'LLP', 'PRTSHP', 'PARTNER', 'LTD', 'INC', 'INCORPORATED', 'CORP', 'CORPORATION', 'COOP', 'CO-OP', 'COMPANY', 'DEPT', 'CITY', 'CTY', 'COUNCIL', 'TRST', 'TRS', 'TR', 'TRUS', 'ESTATE', 'IRA', 'ASSOCIATES', 'ASSOCIATION', 'PARTNERS', 'PARTNERSHIP', 'COUNTY', 'VILLAGE', 'BOARD', 'PARK', 'TOWNSHIP', 'BANK', 'FOUNDATION', 'STREET', 'COMMUNITY', 'SCHOOL', 'CLUB', 'TOWN', 'STEWARDSHIP', 'DIST', 'CO', 'DBA', 'MANAGEMENT', 'CHURCH', 'CHCH', 'CHAPEL', 'CHRISTIAN', 'MONASTERY', 'IMMACULATE', 'NATIONAL', 'ASSOC', 'SERVICE', 'SERVICES', 'LIMITED', 'CEMETERY', 'COMMUNICATIONS', 'TELEPHONE', 'FARM', 'DEPARTMENT', 'FARMS', 'FAMILY', 'FRIENDS', 'DEVELOPMENT', 'CONSTRUCTION', 'INVESTMENTS', 'INVESTMENT', 'PROPERTIES', 'PROPERTY', 'HOMEOWNERS', 'HOMEOWNER', 'AUTHORITY', 'NATURAL', 'AMERICA', 'AMERICAN', 'IOWA', 'BUSINESS', 'TRE']

@acronyms = ['LLC', 'LC', 'LLLP', 'LP', 'L/P', 'LLP', 'PRTSHP', 'PARTNER', 'LTD', 'INC','TRS', 'TR', 'IRA','CO', 'TRE']

@csv_data = []

def find_company?(o1_name, o2_name )
  cap_name = o1_name.upcase
  # check to see if name has any sets of letter variations
  # iterate on co_keywords to check if any words in arr are in the name
  results = cap_name.match?(/(L L C)|(L P)|(L C)|(TRUST)/) || @co_keywords.any? {|word| cap_name.split(' ').include?(word)}
  add_owner_info_to_csv_row(results, o1_name, o2_name)
end

def indiv_name_formatter(name1, name2)
  # binding.pry
  split_name1_by = (name1.scan(/,/).any?) ? ', ' : ' '
  split_name2_by = (name2.scan(/,/).any?) ? ', ' : ' '

  o1_lname, o1_fname = name1.downcase.split(split_name1_by).map(&:capitalize)

  # hand when owner2 is a biz
  seperated_name = name2.downcase.split(split_name2_by).map(&:capitalize)
  # binding.pry
  return [o1_lname, o1_fname] if seperated_name.any?{|word| @co_keywords.include?(word.upcase)}

  o2_lname, o2_fname = [seperated_name.first, seperated_name[1..-1].join(' ')]

  # handle empty name fist name value
  if o1_fname.nil? || o2_fname.nil?
    o1_fname, o2_fname =  [o1_fname, o2_fname].map{|val| (val.nil?) ? val = 'Mr/Ms' : val}
  end
  same_lname = [o1_lname, (o1_fname + ' & ' + o2_fname)]
  diff_lname = [o1_lname, (o1_fname + ' & ' + o2_lname + ' ' + o2_fname)]

  (o1_lname == o2_lname) ? same_lname : diff_lname
end

def add_owner_info_to_csv_row(boolean_results, owner1, owner2)

  if boolean_results
    o_name = owner2.nil? ? owner1 : "#{owner1} & #{owner2}"
    # space for 'Last Name' 'First Name' (2 columns)
    2.times {@new_row << nil}
    # add company name
    co = o_name.downcase.split
    co.map!{|str| @acronyms.include?(str.upcase) ? str.upcase : str.capitalize}
    @new_row << co.join(' ')
    # add type
    @new_row << 'Company'
  else
    #seperate names by comma
    unless owner2.nil?
      split_name = indiv_name_formatter(owner1, owner2)
    else
      # looking for what to split name by
      split_by = (owner1.scan(/,/).any?) ? ', ' : ' '
     split_name = owner1.downcase.split(split_by).map(&:capitalize)
    end
    # binding.pry
    # Owner Last name
    @new_row << split_name.first
    # Owner First name (w/any kind of middle inital/name)
    @new_row << split_name.last
    # add space for Company name column
    @new_row << nil

    # add type
    @new_row << 'Individual'
  end
end

csv_data = CSV.open('PinellasList - PartialHeaderCorrection.csv', 'r', headers: :first_row)

counter = 1
csv_data.each do |row|
  # binding.pry
  @new_row = [row.field('APN')]

  # in county lists owner names aren't seperated
  find_company?(row.field('owner1'), row.field('owner2'))

  # ["Address", "City", "State", "Zip", "Property County", "Property City",
  #    "Property State", "Property Zip", "Market Value", "Property Size",
  #    "Short legal description"]

  @headers[5..-2].each {|col_name| @new_row << row.field(col_name)}
  @new_row << '20191113 - FL - Pinellas Cty'
  @csv_data << @new_row

  # incase there's an issues w/a row will know easier to find row
  counter += 1
  puts counter
end


CSV.open('Formatted_owners.csv', 'w') do |csv|
  csv << @headers
  @csv_data.each {|arr| csv << arr}
end
