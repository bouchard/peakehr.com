#!/usr/bin/env ruby
require 'nokogiri'

class Nokogiri::XML::Node
  def to_a
    c = []
    self.traverse{ |t| c << t.text if t.children.length == 0 }
    c
  end
end

file = File.dirname(__FILE__) + '/ICD10CM_FY2014_Full_XML_DIndex.xml'
f = File.open(file)
doc = Nokogiri::XML(f) do |config|
  config.strict.nonet # Strict parsing, prohibit network connections during parsing.
end
f.close

# <?xml version="1.0" encoding="utf-8"?>
# <ICD10CM.index>
#   <version>2014</version>
#   <title>ICD-10-CM INDEX TO DISEASES and INJURIES</title>
#   <letter>
#     <title>A</title>
#     <mainTerm>
#       <title>Aarskog's syndrome</title>
#       <code>Q87.1</code>
#     </mainTerm>
#     <mainTerm>
#       <title>Abandonment</title>
#       <see>Maltreatment</see>
#     </mainTerm>
#     <mainTerm>
#       <title>Abasia<nemod>(-astasia) (hysterical)</nemod></title>
#       <code>F44.4</code>
#     </mainTerm>
#     <mainTerm>
#       <title>Abderhalden-Kaufmann-Lignac syndrome<nemod>(cystinosis)</nemod></title>
#       <code>E72.04</code>
#     </mainTerm>
#     <mainTerm>
#       <title>Abdomen, abdominal</title>
#       <seeAlso>condition</seeAlso>
#       <term level="1">
#         <title>acute</title>
#         <code>R10.0</code>
#       </term>
#       <term level="1">
#         <title>angina</title>
#         <code>K55.1</code>
#       </term>
#       <term level="1">
#         <title>muscle deficiency syndrome</title>
#         <code>Q79.4</code>
#       </term>
#     </mainTerm>
#     <mainTerm>
#       <title>Abdominalgia</title>
#       <see>Pain, abdominal</see>
#     </mainTerm>
#     <mainTerm>
#       <title>Abduction contracture, hip or other joint</title>
#       <see>Contraction, joint</see>
#     </mainTerm>
#     <mainTerm>
#       <title>Aberrant<nemod>(congenital)</nemod></title>
#       <seeAlso>Malposition, congenital</seeAlso>
#       <term level="1">
#         <title>adrenal gland</title>
#         <code>Q89.1</code>
#       </term>
#       <term level="1">
#         <title>artery<nemod>(peripheral)</nemod></title>
#         <code>Q27.8</code>
#         <term level="2">
#           <title>basilar NEC</title>
#           <code>Q28.1</code>
#         </term>
#         <term level="2">
#           <title>cerebral</title>

class Synonym
  private_class_method :new
  @@synonyms = {}
  def self.add(k, v)
    @@synonyms[k] = v
  end
  def self.all
    @@synonyms
  end
end

def process_term(t, previous_prefix = '')
  prefix = (previous_prefix + ' ' + t.xpath('./title').first.to_a.join(' ')).strip
  if t.xpath('./code').length == 1
    puts "#{prefix} - #{t.xpath('./code').text}"
    # TODO: Do something about synonyms.
    Icd10Code.where(code: t.xpath('./code').text).first_or_create(description: prefix)
  elsif t.xpath('./see').length > 0
    t.xpath('./see').each { |s| Synonym.add(s.text, prefix) }
  elsif t.xpath('./seeAlso').length > 0
    t.xpath('./seeAlso').each { |s| Synonym.add(s.text, prefix) }
  end
  t.xpath('./term').each { |subterm| process_term(subterm, prefix) }
end

doc.css('mainTerm').each do |term|
  process_term(term)
end

# puts Synonym.all.inspect