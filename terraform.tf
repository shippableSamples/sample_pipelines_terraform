# ========================ECS Instances=======================

provider "aws" {}

# EC2 instances
resource "aws_instance" "sampleInstances" {
  count = 2

  # ami = "${var.ecsAmi}"
  ami = "ami-79d45d19"
  #The AMI specified above is a public Ubuntu image, backed by EBS. It was available on AWS at the time of
  #authoring this sample. You can also specify your own AMI image or use any other public EBS backed image if the
  #AMI used in the sample is decommissioned.
  availability_zone = "us-east-1b"   #REPLACE THIS WITH YOUR AVAILABILITY ZONE
  instance_type = "t2.micro"
  subnet_id = "subnet-5bfa2e76"  #REPLACE THIS WITH YOUR SUBNET ID
  associate_public_ip_address = true
  source_dest_check = false

  tags = {
    Name = "sampleInstances-${count.index}"
  }
}
