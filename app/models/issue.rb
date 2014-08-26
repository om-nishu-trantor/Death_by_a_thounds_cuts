class Issue < ParseResource::Base
  fields :Project, :Description, :mitigationPlan, :dateIdentified, :dateResolved, :Status, :Severity, :CommentsArray, :title, :isManagementIssue

  belongs_to :project
end