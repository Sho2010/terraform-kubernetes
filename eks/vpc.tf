####### IMPORTANT NOTE #######
#
# !!!EKSが利用できるCIDRはRFC1918の範囲内!!!
#
# ドキュメント
# ref: https://aws.amazon.com/about-aws/whats-new/2018/10/amazon-eks-now-supports-additional-vpc-cidr-blocks/
# ref: https://docs.aws.amazon.com/ja_jp/AmazonVPC/latest/UserGuide/VPC_Subnets.html
#
# VPC を作成する場合は、 RFC 1918 に指定されているように、プライベート IPv4 アドレス範囲から CIDR ブロック (/16 以下) を指定することをお勧めします。
# 10.0.0.0 - 10.255.255.255 (10/8 プレフィックス)
# 172.16.0.0 - 172.31.255.255 (172.16/12 プレフィックス)
# 192.168.0.0 - 192.168.255.255 (192.168/16 プレフィックス)

data "aws_availability_zones" "available" {}

# refs: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/1.32.0
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name   = "${var.vpc_name}"
  cidr   = "10.0.0.0/16"

  # 2018/11/01現在 ap regionはEKS対応していないのでEKS使う場合はus-east, us-westにする
  azs              = [ "${data.aws_availability_zones.available.names[0]}",
                       "${data.aws_availability_zones.available.names[1]}",
                       "${data.aws_availability_zones.available.names[2]}" ]

  public_subnets   = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  private_subnets  = ["10.0.96.0/20", "10.0.112.0/20", "10.0.128.0/20"]
  database_subnets = ["10.0.144.0/20", "10.0.160.0/20", "10.0.176.0/20"]

  # Your VPC must have DNS hostname and DNS resolution support. Otherwise, your worker nodes cannot register with your cluster. For more information, see Using DNS with Your VPC in the Amazon VPC User Guide.
  enable_nat_gateway   = true
  enable_vpn_gateway   = true
  enable_dns_support   = true
  enable_dns_hostnames = true

  # ref: https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
  tags = "${merge(
    map("Terraform",   "true",
        "Environment", "${var.vpc_name}"),
    "${var.cluster_names}"
  )}"
}

resource "aws_network_acl" "private_acl" {
  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = ["${module.vpc.private_subnets}"]

  # inbound

  # allow VPC internal access
  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "10.0.0.0/16"
    from_port  = 0
    to_port    = 65535
  }

  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags {
    Name = "${var.vpc_name}-private-acl",
    EKSComponent = "true"
  }
}

resource "aws_network_acl" "public_acl" {
  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = ["${module.vpc.public_subnets}"]

  # inbound
  # allow internal access(k8s require)
  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "10.0.0.0/16"
    from_port  = 0
    to_port    = 65535
  }

  # allow application port(if needed direct access to NodePort)
  # NodePort range(default: 30000-32767)だけで(おそらく)十分なはずなので要検証
  ingress {
    rule_no    = 200
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    from_port  = 20000
    to_port    = 65535
  }

  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags {
    Name = "${var.vpc_name}-public-acl",
    EKSComponent = "true"
  }
}

