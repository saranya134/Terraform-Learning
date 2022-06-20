// I have same SG for instances and ELB
resource "aws_security_group" "Terraform-SG" {
  name        = "Terraform-SG"
  description = "This sg is created for webapp"

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Terraform-SG"
  }
}
