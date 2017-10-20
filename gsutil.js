const static_folder = "./static";
const  fs = require("fs");
const exec = require("child_process").execSync;
const list = ["ellobed.js","ellobed.css","footer.html"];

const gsutil_upload= function(file){ return 'gsutil -h "Cache-Control:private" cp ./static/'
			       +file+' gs://ellobed/static'; };

//console.log(exec("echo 'hello world'",{encoding:"utf8"}));


fs.readdir(static_folder, (err, files) => {
    files.forEach(file => {
	if(list.indexOf(file)!==-1){
	    exec(gsutil_upload(file));
	}
    });
});
