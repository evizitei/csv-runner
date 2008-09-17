require 'csv'
require 'date'

module CsvRunner
  DATE_FORMATS = {"MM/DD/YY"=>"%m/%d/%y","MM/DD/YYYY"=>"%m/%d/%Y"}
    
  def get_date_format(format)
    DATE_FORMATS[format]
  end
  
  def csv_run(file,mappings,values,date_format="%m/%d/%Y")
    parsed_file=CSV::Reader.parse(file)
    csv_accumulator=[]
    parsed_file.each_with_index  do |row,i|
      s=self.new
      begin
          
        mappings.each_with_index do |mapping,j|
          val = row[j]
          if(mapping[:type] == :date)
            val = extract_csv_date(val,date_format)
          elsif(mapping[:type] == :int)
            val = extract_int(val)
          elsif(mapping[:type] == :bool)
            val = extract_csv_bool(val)
          elsif(mapping[:type] == :cap_string)
            val = extract_cap_string(val)
          end
          s.send(mapping[:field],val)
        end
        
        values.each {|val| s.send(val[:field],val[:value]) }

        GC.start if i%50==0
        yield csv_accumulator,s
        
      rescue Exception => e
       csv_accumulator.push("ERROR: index: #{i}   message: #{e.message}")
      end
    end
    
    return csv_accumulator
  end
  
  def extract_csv_date(val,format="%m/%d/%Y")
    return nil unless (!val.nil? and val.length > 0)
    
    d = Date.strptime(val,format) 
    (((Date.today << (30*12)) > d) and ((Date.today) > d >> 1200)) ? (d >> 1200) : d;
  end
  
  def extract_csv_bool(val)
    ((val.nil? || val == "") ? false : (val == "Y" or val == "y" ? true : false))
  end
  
  def extract_cap_string(val)
    val.upcase
  end
  
  def extract_int(val)
    val.to_i
  end
end