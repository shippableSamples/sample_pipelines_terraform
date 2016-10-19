# ========================ECS Instances=======================

provider "aws" {}

# EC2 instances
resource "aws_instance" "sampleInstances" {
  count = 2

  # ami = "${var.ecsAmi}"
  ami = "ami-0d729a60"
  availability_zone = "us-east-1b"   #REPLACE THIS WITH YOUR AVAILABILITY ZONE
  instance_type = "t2.micro"
  subnet_id = "subnet-5bfa2e76"  #REPLACE THIS WITH YOUR SUBNET ID
  associate_public_ip_address = true
  source_dest_check = false

  tags = {
    Name = "sampleInstances-${count.index}"
  }
}
