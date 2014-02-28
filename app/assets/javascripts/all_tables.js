function configureIssueTable(tableNode) {
    var table = tableNode, oTable = table.dataTable({
        /*
		 * We set specific options for each columns here. Some columns contain raw data to enable correct sorting, so we convert it for display
		 * @url http://www.datatables.net/usage/columns
		 */
        aoColumns : [{
            bSortable : false
        },{
            bSortable : 'string'
        },{
            bSortable : 'string'
        },{
            bSortable : 'string'
        },{
            bSortable : 'string'
        },{
            bSortable : 'string'
        },{
            bSortable : 'string'
        },{
            bSortable : false
        }], 
        sPaginationType:"full_numbers",
        "sDom":'T<"clear">lfrtip',
        "oTableTools": {
            "aButtons": [
                
            ]
        }
		
    });
    
};

$(function() {
    $('#table-issues').each(function(i) {
        configureIssueTable($(this));
    });
});
