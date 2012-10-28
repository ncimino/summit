function auto_fill(id, value, force) {
    if (force || $(id).val() == "") {
        $(id).val(value);
    }
}

function set_defaults(name, force) {
    auto_fill("#website_domain", name + ".econtriver.com", force)
    auto_fill("#website_deploy_path","/srv/www/" + name + ".econtriver.com", force)
    auto_fill("#website_post_receive_path","/home/g/repositories/" + name + ".git/hooks/post-receive", force)
    auto_fill("#website_nginx_path","/etc/nginx/sites-available/" + name + ".econtriver.com", force)
    auto_fill("#website_enabled_nginx_path","/etc/nginx/sites-enabled/" + name + ".econtriver.com", force)
    auto_fill("#website_git_repo_path","/home/g/repositories/" + name + ".git", force)
    auto_fill("#website_enabled_git_path","/srv/www/git.econtriver.com/public_html/" + name + ".git", force)
}

$(document).ready(function(){
    $("#website_name").focus().change(function() {
        set_defaults($(this).val().toLowerCase());
    });
    $("#reload").click(function() {
        set_defaults($("#website_name").val().toLowerCase(), true);
    });
    $(".clearfield").click(function() {
        $(this).prev("input.text").val('');
        $(this).prev("div").children("input.text").val('');
    });
});