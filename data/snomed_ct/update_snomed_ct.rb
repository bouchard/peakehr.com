#!/usr/bin/env ruby
require 'csv'
require 'zip'

to_unzip = File.dirname(__FILE__) + '/Full.zip'
Zip::File.open(to_unzip) do |zip_file|

  file = Tempfile.new('snomed')
  file.binmode
  file.write(zip_file.glob('Full/Terminology/sct2_Description_Full*.txt').first.get_input_stream.read)

  File.foreach(file) do |line|
    begin
      CSV.parse(line, { col_sep: "\t", encoding: 'ISO-8859-1' }) do |row|
        puts "#{row[7]}"
        SnomedTerm.create!(
          description: row[7],
          code: row[0]
        )
      end
    rescue CSV::MalformedCSVError => e
      puts "BAD LINE: #{line}"
    end
  end
  file.close

end

# id  effectiveTime active  moduleId  conceptId languageCode  typeId  term  caseSignificanceId
# 2958068015  20130731  1 900000000000207008  609090006 en  900000000000003001  Schistosoma mansoni worm (organism) 900000000000017005
# 2966076014  20130731  1 900000000000207008  5074003 en  900000000000003001  Fetal or neonatal effect of placentitis (disorder)  900000000000020002
# 2966528016  20130731  1 900000000000207008  59363009  en  900000000000013009  Inevitable miscarriage  900000000000020002
# 2966310019  20130731  1 900000000000207008  85116003  en  900000000000003001  Miscarriage in second trimester (disorder)  900000000000020002
# 2958069011  20130731  1 900000000000207008  608827009 en  900000000000003001  Open reduction of epiphyseal fracture of radius and ulna with internal fixation (procedure) 900000000000020002
# 2967036011  20130731  1 900000000000207008  198749004 en  900000000000013009  Incomplete illegal termination of pregnancy with shock  900000000000020002
# 2958070012  20130731  1 900000000000207008  608931002 en  900000000000003001  Trophozoite form of Genus Giardia (organism)  900000000000020002
# 2958071011  20130731  1 900000000000207008  609005006 en  900000000000013009  Larval form of Genus Schistosoma  900000000000020002
# 2966077017  20130731  1 900000000000207008  18001006  en  900000000000003001  Fetal or neonatal effect of multiple pregnancy (disorder) 900000000000020002
# 2965712019  20130731  1 900000000000207008  206017000 en  900000000000003001  Fetal or neonatal effect of placental or breast transfer of narcotics (disorder)  900000000000020002
# 2958072016  20130731  1 900000000000207008  609155001 en  900000000000013009  Percutaneous transcatheter coil embolization of fistula of coronary artery using fluoroscopic guidance  900000000000020002
# 2966571013  20130731  1 900000000000207008  420146005 en  900000000000013009  Cerebral degeneration in lipidoses  900000000000020002
# 2966078010  20130731  1 900000000000207008  111460005 en  900000000000013009  Fetal or neonatal effect of hallucinogenic agent transmitted via placenta and/or breast milk  900000000000020002
# 2967037019  20130731  1 900000000000207008  198761007 en  900000000000013009  Complete illegal termination of pregnancy with shock  900000000000020002
# 2958073014  20130731  1 900000000000207008  609101000 en  900000000000003001  Microscopic cytologic examination of smear of lymph fluid specimen prepared using Papanicolaou technique (procedure)  900000000000020002
# 2958074015  20130731  1 900000000000207008  608983009 en  900000000000013009  Worm form of fluke
