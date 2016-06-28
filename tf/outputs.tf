output "address" {
  value = "${aws_elb.web-elb.dns_name}"
}

#output "web_server" {
#  value = "${aws_instance.web.dns_name}"
#}

#output "app_server" {
#  value = "${aws_instance.app.dns_name}"
#}


#output "subnet_ids_web_a" {
#  value = "${join(",", aws_subnet.interview_prod_web_a.*.id)}"
#}

#output "subnet_ids_web_a" {
#  value = "${join(",", aws_subnet.interview_prod_web_b.*.id)}"
#}

#output "subnet_ids_web_c" {
#  value = "${join(",", aws_subnet.interview_prod_web_c.*.id)}"
#}

output "subnet_ids_app" {
  value = "${join(",", aws_subnet.interview_public.*.id)}"
}

output "security_group" {
  value = "${aws_security_group.web-sg.id}"
}
output "launch_configuration" {
  value = "${aws_launch_configuration.web-lc.id}"
}
output "asg_name" {
  value = "${aws_autoscaling_group.web-asg.id}"
}
output "elb_name" {
  value = "${aws_elb.web-elb.dns_name}"
}