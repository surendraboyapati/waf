resource "aws_wafregional_ipset" "ipset" {
  name = var.aws_wafregional_ipset_name
  ip_set_descriptor {
    type  = "IPV4"
    value = "192.0.7.0/24"
  }
}

resource "aws_wafregional_rule" "regionalRule" {
  name        = var.aws_wafregional_rule_name
  metric_name = var.aws_wafregional_rule_metric_name
  predicate {
    data_id = aws_wafregional_ipset.ipset.id
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_wafregional_web_acl" "webAcl" {
  name        = var.aws_wafregional_web_acl_name
  metric_name = var.aws_wafregional_web_acl_metric_name

  default_action {
    type = "ALLOW"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 1
    rule_id  = aws_wafregional_rule.regionalRule.id
  }
}
 
data "aws_lb" "awsLb" {
  name = var.lb_name
}

resource "aws_wafregional_web_acl_association" "association" {
  resource_arn = data.aws_lb.awsLb.arn
  web_acl_id   = aws_wafregional_web_acl.webAcl.id
}