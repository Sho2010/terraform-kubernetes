module "eks" {
  source       = "terraform-aws-modules/eks/aws"

  cluster_name    = "${terraform.workspace}-eks-cluster"
  cluster_version = "1.10"
  vpc_id          = "${module.vpc.vpc_id}"
  subnets         = ["${module.vpc.public_subnets}"]

  tags            = "${map("Environment", "${terraform.workspace}")}"

  # https://github.com/terraform-aws-modules/terraform-aws-eks/blob/2814efcb8a9940b5132a9ab93b58114de47f6ac0/variables.tf#L77-L99
  worker_groups = [
    {
      instance_type = "t2.medium",
      public_ip = false,            # MEMO: trueにしてもk8s ExternalIPが割り振られなくてつらい
    },
  ]

  # NOTE:
  # User permissions  ref:  https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/1.3.0/examples/eks_test_fixture?tab=inputs
  # map_roles = [
  #  {
  #    "group"= "system:masters",
  #    "role_arn"= "arn:aws:iam::66666666666:role/role1",
  #    "username"= "role1"
  #  }
  #]

  map_users = [
    { "group" = "system:masters", "user_arn" = "arn:aws:iam::xxxxxxxxxxxx:user/sho2010",  "username" = "sho2010" },
  ]
}

output "kubeconfig" {
  value = "${module.eks.kubeconfig}"
}
