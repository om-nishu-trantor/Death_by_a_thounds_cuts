class Issues < ParseResource::Base
	 fields :Project, :Description, :mitigationPlan, :dateIdentified, :dateResolved, :Status, :Severity, :CommentsArray, :title, :isManagementIssue

   validates :title, :presence => true

  def self.import(file, current_userName)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      create_issue(row, current_userName)
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".xlsx" then Roo::Excelx.new(file.path, packed: nil, file_warning: :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def self.create_issue(row, current_userName)

    row = row.select {|k,v| ["Project","title", "Description", "mitigationPlan", "dateIdentified", "Status", "Severity", "assignedTo","isManagementIssue", "isClosed", "createdBy"].include?(k) }
    row["Project"] = ((row["Project"]).strip).upcase
    row["isClosed"] = row["isClosed"] == "true" ? true : false

    row["isManagementIssue"] = row["isManagementIssue"] == "true" ? true : false
    row["isDeleted"] = false

    row["assignedTo"] = 'RAJAT JULKA' if row["isManagementIssue"] == true

    row["assignedTo"] = row["assignedTo"].blank? ? 'RAJAT JULKA' : row["assignedTo"]

    row["createdBy"] = current_userName
    row["CommentsArray"] = []

    # Create the record for the issue.
    issue = Issues.new(row) 
    raise 'Headers/values are not in proper format' and return unless issue.save
  end

end