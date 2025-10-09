# frozen_string_literal: true

puts "Seeding GDPR Compliance Areas..."

compliance_areas = [
  {
    name: "Lawfulness, Fairness, Transparency",
    code: "GDPR-PRINCIPLE-1",
    description: "Processing must be lawful, fair and transparent to the data subject"
  },
  {
    name: "Purpose Limitation",
    code: "GDPR-PRINCIPLE-2",
    description: "Data must be collected for specified, explicit and legitimate purposes"
  },
  {
    name: "Data Minimization",
    code: "GDPR-PRINCIPLE-3",
    description: "Data must be adequate, relevant and limited to what is necessary"
  },
  {
    name: "Accuracy",
    code: "GDPR-PRINCIPLE-4",
    description: "Data must be accurate and kept up to date"
  },
  {
    name: "Storage Limitation",
    code: "GDPR-PRINCIPLE-5",
    description: "Data must be kept only as long as necessary"
  },
  {
    name: "Integrity and Confidentiality",
    code: "GDPR-PRINCIPLE-6",
    description: "Data must be processed securely"
  },
  {
    name: "Accountability",
    code: "GDPR-PRINCIPLE-7",
    description: "Controller must demonstrate compliance"
  },
  {
    name: "Records of Processing Activities",
    code: "GDPR-ART-30",
    description: "Maintain records of all processing activities (Article 30)"
  },
  {
    name: "Security of Processing",
    code: "GDPR-ART-32",
    description: "Implement appropriate technical and organizational measures (Article 32)"
  },
  {
    name: "Data Protection Impact Assessment",
    code: "GDPR-ART-35",
    description: "Conduct DPIA for high-risk processing (Article 35)"
  },
  {
    name: "Data Protection Officer",
    code: "GDPR-ART-37",
    description: "Designate a DPO when required (Article 37)"
  }
]

compliance_areas.each do |area_data|
  Gdpr::ComplianceArea.find_or_create_by!(code: area_data[:code]) do |area|
    area.name = area_data[:name]
    area.description = area_data[:description]
  end
end

puts "✓ Created #{Gdpr::ComplianceArea.count} GDPR compliance areas"
