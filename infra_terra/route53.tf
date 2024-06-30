# resource "aws_route53_record" "www-live" {
#   zone_id = aws_route53_zone.primary.zone_id
#   name    = "www"
#   type    = "CNAME"
#   ttl     = 5

#    records = [aws_lb.MYALB.dns_name]


#using apex domain
# resource "aws_route53_record" "alias_route53_record" {
#   zone_id = aws_route53_zone.primary.zone_id # Replace with your zone ID
#   name    = "example.com" # Replace with your name/domain/subdomain
#   type    = "A"

#   alias {
#     name                   = aws_lb.MYALB.dns_name
#     zone_id                = aws_lb.MYALB.zone_id
#     evaluate_target_health = true
#   }
# }

# resource "aws_route53_zone" "myZone" {
#   name = "example.com"
# }

# resource "aws_route53_record" "myRecord" {
#   zone_id = aws_route53_zone.myZone.zone_id
#   name    = "www.example.com"
#   type    = "CNAME"
#   ttl     = 60
#   records = [aws_lb.MYALB.dns_name]
# }