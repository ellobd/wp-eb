jQuery(document).ready(function(){
    var $ = jQuery;
    var attr_el = $("#login>h1>a");
    attr_el.attr("title","Enriching global hospitality ecosystem");
    attr_el.attr("href","/");
    $("body").append("<div id='eb_external_footer'></div>");
    $("#eb_main_footer").load("https://storage.googleapis.com/ellobed/static/footer.html #eb_main_footer",function(){
	console.log("footer_loaded");
    });
    console.log("hello world");
});

