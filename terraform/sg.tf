resource "aws_security_group" "skmt_sg" {
  name        = "skmt_sg"
  description = "Security Group for SKMT VPC"
  vpc_id      = aws_vpc.skmt_vpc.id

  tags = {
    Name = "skmt_sg"
  }
}

resource "aws_security_group_rule" "skmt_sg_rule_egress" {
  security_group_id = aws_security_group.skmt_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}