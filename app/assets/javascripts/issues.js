$(document).ready(function(){
	$('.datepicker').datepicker({
		format : 'dd-mm-yyyy'
	});
	$("checkbox").bootstrapSwitch();
	$('#project_list_drop').change(function() {
    	var val = $("#project_list_drop option:selected").text();
    	$.blockUI({ css: { 
	            border: 'none', 
	            padding: '15px', 
	            backgroundColor: '#000', 
	            '-webkit-border-radius': '10px', 
	            '-moz-border-radius': '10px', 
	            opacity: .5, 
	            color: '#fff' 
        	} 
    	}); 
	    	$.get('/issues/fetch_issue',{'project': val} , function(data){
	    		$('.project_list_div').empty();
	    		$('.project_list_div').html(data)
	    		$.unblockUI();
	    		configureIssueTable($('#table-issues'));
	    	});	
    });

	$('.find_issues').on('click',function(){
		var project = $('#project_list_report').val();
		var start_date = $('#dateStartReport').val();
		var end_date = $('#dateEndReport').val();
		if(project.length == 0 || start_date.length == 0 || end_date.length == 0  )
		{
			alert("please enter information")
			return false;

		}else{
			if($(this).attr('data_pdf') == "true")
			{
				$.get('/issues/pdf_report.pdf',{'project': project , 'start_date': start_date , 'end_date': end_date} , function(data){
	    		});
			}else{	
				$.blockUI({ css: { 
		            border: 'none', 
		            padding: '15px', 
		            backgroundColor: '#000', 
		            '-webkit-border-radius': '10px', 
		            '-moz-border-radius': '10px', 
		            opacity: .5, 
		            color: '#fff' 
	        	}
        	});
        	$.get('/issues/fetch_issue_report',{'project': project , 'start_date': start_date , 'end_date': end_date} , function(data){
	    		$('.project_list_report_div').empty();
	    		$('.project_list_report_div').html(data)
	    		$.unblockUI();
	    		configureIssueReportTable($('#table-issues-report'));
	    	});
        }
		}

	});


	$('#create_issue').on('click',function(){
		var name = $('#issue_user_name').val();
		var isClosed = false
		var closedBy = '' 
		var project =  $('#new_issue_create_form #project').val();
		var description =  $('#new_issue_create_form #description').val(); 
		var mitigationPlan =  $('#new_issue_create_form #mitigationPlan').val();
		var dateIdentified =  $('#new_issue_create_form #dateIdentified').val();
		var dateResolved =  $('#new_issue_create_form #dateResolved').val();
		var status =  $('#new_issue_create_form #status').val();
		var severity =  $('#new_issue_create_form #severity').val();
		var manageable = $('#new_issue_create_form #ismanageable').prop('checked');
		var assignedto = $('#new_issue_create_form #assignedto').val();

		if(manageable == true)
		{
			assignedto = ''
		}

		if(status == "CLOSED"){
			isClosed = true
			closedBy = name
		}

        data_form  = {
            'issues[Project]' : project,
            'issues[Description]' : description,
            'issues[mitigationPlan]' : mitigationPlan,
            'issues[dateIdentified]' : dateIdentified,
            'issues[dateResolved]' : dateResolved,
            'issues[Status]' : status,
            'issues[Severity]' : severity,
            'issues[isClosed]' : isClosed,
            'issues[closedBy]' : closedBy,
            'issues[isManagementIssue]' : manageable,
            'issues[assignedTo]' : assignedto
        }
        $('#create_new_issue').modal('hide')
        $.blockUI({ css: { 
	            border: 'none', 
	            padding: '15px', 
	            backgroundColor: '#000', 
	            '-webkit-border-radius': '10px', 
	            '-moz-border-radius': '10px', 
	            opacity: .5, 
	            color: '#fff' 
        	} 
    	});
        $.post('/issues', data_form, function(data){
        	$('.project_list_div').empty();
    		$('.project_list_div').html(data)
    		$.unblockUI();
    		configureIssueTable($('#table-issues'));
    		$("#new_issue_div").toggle();
    		$('#new_issue_create_form')[0].reset()
    		document.getElementById("assignedto").disabled=false;
        });
	});


	$('.create_new_issue').on('click',function(){
		$("#new_issue_div").collapse('toggle');
		// $("#update_issue_div").hide();
	});	

	$('#update_issue').on('click',function(){
		$("#update_issue_div").toggle();
		$("#new_issue_div").hide();
	});	

	$(".project_list_div").delegate(".issue_delete", "click", function(event) {
		event.preventDefault();
		object_id = $(this).attr('data_id')
		$.blockUI({ css: { 
	            border: 'none', 
	            padding: '15px', 
	            backgroundColor: '#000', 
	            '-webkit-border-radius': '10px', 
	            '-moz-border-radius': '10px', 
	            opacity: .5, 
	            color: '#fff' 
        	} 
    	});
		$.ajax({
	    	url: '/issues/'+object_id,
	    	type: 'DELETE',
	    	success: function(result) {
	    		$('.project_list_div').empty();
	    		$('.project_list_div').html(result)
	    		$.unblockUI();
	    		configureIssueTable($('#table-issues'));
	    	}
		});
	});

	$('#new_issue_create_form #status').change(function(){
		var val = $("#new_issue_create_form #status option:selected").text();
		if(val == "CLOSED"){
			$('#dateResolved').val(Date.today().toString("dd-MM-yyyy"))
			$('#issues_dateResolved').val(Date.today().toString("dd-MM-yyyy"))
			
		}else{
			$('#dateResolved').val('')
		}
	});

	$('.edit_issues #issues_Status').change(function(){
		var val = $(".edit_issues #issues_Status option:selected").text();
		if(val == "CLOSED"){
			$('#issues_dateResolved').val(Date.today().toString("dd-MM-yyyy"))
			
		}else{
			$('#issues_dateResolved').val('')
		}
	});



	$('#new_issue_create_form #ismanageable').change(function(){
		if($('#new_issue_create_form #ismanageable').prop('checked')){
			document.getElementById("assignedto").disabled=true;
			document.getElementById("assignedto").value = "Please Select"
		}else
		{
			document.getElementById("assignedto").disabled=false;
		}
	});	
		
	$(".project_list_div").delegate("#panel-body-active button", "click", function(event) {	
		$('#panel-body-active button').removeClass('active');
		$(this).addClass('active');
	});


});	

