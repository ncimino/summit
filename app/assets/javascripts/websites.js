function auto_fill(id, value) {
    if ($(id).val() == "") {
        $(id).val(value);
    }
}

$(document).ready(function(){
    $("#website_name").change(function() {
        auto_fill("#website_domain",$(this).val().toLowerCase() + ".econtriver.com")
        auto_fill("#website_deploy_path","/srv/www/" + $(this).val().toLowerCase() + ".econtriver.com")
        auto_fill("#website_post_receive_path","/home/g/repositories/" + $(this).val().toLowerCase() + ".git/hooks/post-receive")
        auto_fill("#website_nginx_path","/etc/nginx/available-sites/" + $(this).val().toLowerCase() + ".econtriver.com")
    });
});