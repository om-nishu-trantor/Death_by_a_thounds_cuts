function configureIssueTable(tableNode) {
    var table = tableNode, oTable = table.dataTable({
        /*
		 * We set specific options for each columns here. Some columns contain raw data to enable correct sorting, so we convert it for display
		 * @url http://www.datatables.net/usage/columns
		 */
        aoColumns : [
        { "bVisible" : false 
        },{
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

    $('.filter-btn-ser').on('click', function(){
        var val = $(this).attr("data-text");
        oTable.fnFilter(val,null,true,true,true,false);  
    });

    $('.filter-btn-stat').on('click', function(){
        table_fil = $('#table-issues').dataTable();
        table_fil.fnFilter("CLOSED",null,true,true,true,false);  
    });
    
    $('.filter-btn-all').on('click', function(){
        table_fil = $('#table-issues').dataTable();
        table_fil.fnFilter('');  
    });
    
};

function configureIssueReportTable(tableNode) {
    var table = tableNode, oTable = table.dataTable({
        /*
         * We set specific options for each columns here. Some columns contain raw data to enable correct sorting, so we convert it for display
         * @url http://www.datatables.net/usage/columns
         */
        aoColumns : [
        {
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
    $('#table-issues-report').each(function(i) {
        configureIssueReportTable($(this));
    });
});



