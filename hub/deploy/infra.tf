# data "aws_ami" "redhat7" {
#   most_recent = true

#   filter {
#     name   = "ImageId"
#     values = ["ami-013984d976f6d6894"]
#   }
# }

resource "aws_instance" "web" {
  ami           = var.hub_ami_id
  instance_type = var.hub_instance_type

  tags = {
    Name = "HelloWorld"
  }
}