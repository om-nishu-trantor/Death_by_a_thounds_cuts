class Issues < ParseResource::Base
	 fields :Project, :Description, :mitigationPlan, :dateIdentified, :dateResolved, :Status, :Severity, :CommentsArray, :title, :isManagementIssue

  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      # issue = find_by_id(row["id"]) || new
      # product.attributes = row.to_hash.slice(*accessible_attributes)
      # product.save!
      create_issue(row)
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Roo::Csv.new(file.path, packed: nil, file_warning: :ignore)
    when ".xls" then Roo::Excel.new(file.path, packed: nil, file_warning: :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, packed: nil, file_warning: :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def self.create_issue(row)
    row = row.except("S.No")
    row["Project"] = ((row["Project"]).strip).upcase
    row["isClosed"] = row["isClosed"] == "true" ? true : false
    row["isManagementIssue"] = row["isManagementIssue"] == "true" ? true : false
    row["isDeleted"] = false

    # Set assigned_to with UserId name.
    row["assignedTo"] = 'RAJAT JULKA' if row["isManagementIssue"] = "true"

    row["assignedTo"] = row["assignedTo"].blank? ? 'RAJAT JULKA' : row["assignedTo"]

    row["createdBy"] = 'Sunia'#current_user.Name
    row["CommentsArray"] = []

    new_issue = Issues.new(row)
    new_issue.save
  end

end