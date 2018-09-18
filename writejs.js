function myFunction() {
var name = document.getElementById("name").value;
var description = document.getElementById("description").value;

// Returns successful data submission message when the entered information is stored in database.
var dataString = 'name1=' + name + 'description1=' + description;
if (name == '' || description == '') {
alert("Please Fill All Fields");
} else {
// AJAX code to submit form.
$.ajax({
type: "POST",
url: "writephp.php",
data: dataString,
cache: false,
success: function(html) {
alert(html);
}
});
}
return false;
}