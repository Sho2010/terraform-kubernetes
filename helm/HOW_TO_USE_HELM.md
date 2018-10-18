# これは何？

k8s cluster上に[helm](https://helm.sh/)を用いて
prometheusを構築するためのdirectory

## Create helm RBAC role

NOTE: Require k8s admin permission

### まずは既にinstallされてないかチェック

~~~
# 以下のコマンドを実行して既にservice account, podが存在していれば
# 既にインストールされているのでhelmのinstallは飛ばして構わない
$ kubectl get sa --namespace kube-system | grep tiller
tiller       1         24d

$ kubectl get  pod --namespace kube-system | grep tiller
tiller-deploy-5c688d5f9b-jjstz   1/1       Running   0          24d
~~~

~~~
$ cd helm
$ kubectl create -f ./rbac-config.yaml
$ helm init --service-account tiller
~~~

`helmのインストールはこれで終わり`
ここからはhelmを使ってprometheusのインストールをしてみる

## variable extract & edit

以下のコマンドですべての設定が書かれた生成できる。
sampleとして `prometheus/prometheus_values.yaml.sample` に保存してある

~~~
$ helm inspect values stable/prometheus > prometheus_values.yaml
$ $EDITOR prometheus_values.yaml
~~~

## configure example

refs: https://github.com/kubernetes/charts/tree/master/stable/prometheus#configuration

フルの設定ファイルだとでかすぎてめんどくさいので、変更する値だけ書かれたvalues fileを作成する。
(MQの場合は今の所type: load balancer書いてるので若干内容が異なります)

`./prometheus/values.yaml`

~~~yaml
# 設定例
# PDCを使わない
# LBを使わないで直接NodePortで参照する
# `ClusterIP適当に適切なものを入れる`　自動で振る方法がよくわからない
server:
  persistentVolume:
    enabled: false
  service:
    clusterIP: "10.59.242.1"
    type: "NodePort"
    nodePort: 30080

alertmanager:
  persistentVolume:
    enabled: false
  service:
    clusterIP: "10.59.242.2"
    type: "NodePort"
    nodePort: 30090
~~~

## 実行されるmanifestを覗いてみる

~~~
$ helm fetch stable/prometheus
$ helm template prometheus-6.8.0.tgz -v prometheus/values.yaml
~~~

## install prometheus

~~~
$ helm install stable/prometheus --name prometheus --namespace prometheus --values prometheus/values.yaml
~~~

