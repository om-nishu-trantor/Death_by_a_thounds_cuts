class Issues < ParseResource::Base
	 fields :Project, :Description, :mitigationPlan, :dateIdentified, :dateResolved, :Status, :Severity
end