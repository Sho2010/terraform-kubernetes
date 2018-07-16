# これはなに?

基本的なGKEのclusterを構築するためのterraform

# How to use

## Set your service key

ref: https://www.terraform.io/docs/providers/google/index.html

Please set `GOOGLE_CLOUD_KEYFILE_JSON` environment service account key path

## (Optional) Copy assign variable file

~~sh
$ cp variables.auto.tfvars.sample variables.auto.tfvars
$ ${EDITOR} variables.auto.tfvars
~~~

## terraform initialize

~~~sh
$ terraform init
~~~

## execute

~~~
$ terraform plan
$ terraform apply
~~~
