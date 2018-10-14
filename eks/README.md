# これなに?

AWSに環境を立てるためのterraform file
現在以下のコンポーネントをAWS resourceをsetupする

* VPC
* EKS

# Pre requirements

* terraform
* aws-iam-authenticator(github.com/kubernetes-sigs/aws-iam-authenticator)
* kubectl(`version 1.10 higher`)

~~~sh
$ brew install terraform
$ go get -u -v github.com/kubernetes-sigs/aws-iam-authenticator/cmd/aws-iam-authenticator
~~~

# edit secrets

機密情報を設定 access key, secret keyを設定
実行時に `secret.auto.tfvars` が読み込まれる(実行時にargとして指定することも可能)

~~~
$ cp secret.auto.tfvars.sample secret.auto.tfvars
$ ${EDITOR} secret.auto.tfvars
~~~

secret.auto.tfvars

~~~
access_key = "YOUR_AWS_ACCESS_KEY"
secret_key = "YOUR_AWS_SECRET_KEY"
~~~

# initialize

~~~
$ terraform init
$ terraform plan # 今の状態を表示する
~~~

# AWS Consoleへ

Consoleに移動して各種リソースが作成されているか確認する

* VPC
* subnet
* network acl
* eks instance
* eks auto scale group

etc...etc...

- - -

# EKSに`kubectl` で接続する

既存のclusterが存在する場合
`$ terraform output`

~~~
# 既存の~/.kube/config がある場合 よろしくやる
mv kubeconfig_k8s-eks-cluster ~/kubeconfig_k8s-eks-cluster
export KUBECONFIG=~/kubeconfig_k8s-eks-cluster
~~~

### トラブルシューティング

* kubectlを実行後にUsernameの入力を求められる

kubectlのversionが1.10以前のものです 1.10以降を使ってください

それでも繋がらない場合はaws-iam-authenticatorがinstall, pathが通ってることを確認してください。

それでも繋がらない場合は多分clusterに権限がありません

