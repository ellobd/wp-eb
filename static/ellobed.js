jQuery(document).ready(function(){
    var $ = jQuery;
    var url= window.location.href;
    var page_blocks=["wp-admin","wp-login"];
    var blocked = [];
    //check if the page is blocked    
    for(var i=0;i<page_blocks.length;i++){
	if(url.indexOf(page_blocks[i])!==-1){
	    blocked.push(true);
	}

    }
    
    if(blocked.length===0){
	// The page is not blocked
	// execute the code that follows
	
	var attr_el = $("#login>h1>a");	
	attr_el.attr("title","Enriching global hospitality ecosystem");
	attr_el.attr("href","/");
	$("body").append("<div id='eb_external_footer'></div>");
	$("#eb_external_footer")
	    .load("https://storage.googleapis.com/ellobed/static/footer.html #eb_main_footer",
		  function(){
		      console.log("footer_loaded");
		  });
	
    }

});

