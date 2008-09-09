require 'csv'

module CsvRunner
  
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
          elsif(mapping[:type] == :bool)
            val = extract_csv_bool(val)
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
    (((Date.today - 30.years) > d) and ((Date.today) > d + 100.years)) ? (d + 100.years) : d;
  end
  
  def extract_csv_bool(val)
    ((val.nil? || val == "") ? false : (val == "Y" or val == "y" ? true : false))
  end
end